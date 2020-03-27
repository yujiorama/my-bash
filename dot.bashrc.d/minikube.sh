# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

function add-user-to-hyperadmingroup {
    local ps1_file
    ps1_file="$(mktemp --suffix=.ps1 --tmpdir="${TMP}")"

    cat - <<-'EOS'  > "${ps1_file}"
$currentUser = "WinNT://$env:UserDomain/$env:Username"
$hvGroup = ([adsi]"WinNT://./Hyper-V Administrators,group")
$members = @($hvGroup.psbase.invoke("Members") | %{ $_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null) })
echo $members
if (! $members.Contains($currentUser)) {
    $hvGroup.Add("$currentUser,user")
}
EOS

    sudo powershell -file "${ps1_file}"
    rm -f "${ps1_file}"
    return 0
}

function configure-vswitch {
    local ps1_file vSwitchName
    ps1_file="$(mktemp --suffix=.ps1 --tmpdir="${TMP}")"
    vSwitchName="${1}"

    cat - <<-'EOS' > "${ps1_file}"
Param(
    [string]$vSwitchName = "Default Switch"
)

Write-Host $vSwitchName

$vSwitch = Get-VMSwitch -Name $vSwitchName
if ($vSwitch) {
    if ($vSwitch.SwitchType -eq "External") {
        return 0
    }
    Remove-VMSwitch -Name $vSwitchName -Force -ErrorAction Ignore
}
$newSwitch = New-VMSwitch -SwitchName $vSwitchName -SwitchType Internal
$netAdapter = Get-NetAdapter | Where Name -eq "vEthernet ($vSwitchName)"
if (! $netAdapter) {
    return 0
}
Remove-NetIPAddress -IPAddress 192.168.199.1 -Confirm:$false -ErrorAction Ignore
$newNetIP = New-NetIPAddress -IPAddress 192.168.199.1 -PrefixLength 24 -InterfaceIndex $netAdapter.ifIndex

$networkName = "$vSwitchName Network"
Remove-NetNat -Name $networkName -Confirm:$false -ErrorAction Ignore
$newNat = New-NetNat -Name $networkName -InternalIPInterfaceAddressPrefix 192.168.199.0/24

$netAdapter = Get-NetAdapter | Where Name -eq "vEthernet ($vSwitchName)"
if (! $netAdapter) {
    return 0
}

# disable IPv6
Disable-NetAdapterBinding -Name $netAdapter.Name -ComponentID ms_tcpip6

# private profile
Set-NetConnectionProfile -InterfaceIndex $netAdapter.ifIndex -NetworkCategory Private -ErrorAction Ignore
EOS

    sudo powershell -file "${ps1_file}" -vSwitchName \""${vSwitchName}"\"
    rm -f "${ps1_file}"
    return 0
}

function minikube-running {
    local running
    running=$(minikube status 2>/dev/null| grep -c -E '(host|kubelet|apiserver): Running')
    [[ ${running} -eq 3 ]] && return 0
    return 1
}

function minikube-start-hyperv {
    local profile="minikube"
    local vSwitchName="Minikube Switch"
    local runtime="docker"
    local cpus="4"
    local memorysize="8g"
    local disksize="60g"
    local dockerOptBip="bip=10.1.0.5/24"
    local dockerOptFixedCidr="fixed-cidr=10.1.0.5/25"
    local registry
    registry="${HOSTNAME}.$(echo "${USERDNSDOMAIN}" | tr '[:upper:]' '[:lower:]'):5000"

    local OPTIND OPTARG
    while getopts "hp:v:r:c:m:d:g:" opt; do
        case "${opt}" in
            p) profile="${OPTARG}";;
            v) vSwitchName="${OPTARG}";;
            r) runtime="${OPTARG}";;
            c) cpus="${OPTARG}";;
            m) memorysize="${OPTARG}";;
            d) disksize="${OPTARG}";;
            g) registry="${OPTARG}";;
            h) return 1;;
            *) return 1;;
        esac
    done

    add-user-to-hyperadmingroup

    configure-vswitch "${vSwitchName}"

    sudo minikube start \
        --vm-driver hyperv \
        --profile \""${profile}"\" \
        --hyperv-virtual-switch \""${vSwitchName}"\" \
        --container-runtime \""${runtime}"\" \
        --cpus \""${cpus}"\" \
        --memory \""${memorysize}"\" \
        --disk-size \""${disksize}"\" \
        --docker-opt \""${dockerOptBip}"\" \
        --docker-opt \""${dockerOptFixedCidr}"\" \
        --insecure-registry \""${registry}"\" \
        --logtostderr

    return 0
}

function dns-serverline {
    local ps1_file localdns
    ps1_file="$(mktemp --suffix=.ps1 --tmpdir="${TMP}")"

    cat - <<-'EOS' > "${ps1_file}"
$i = Get-NetIPAddress -AddressFamily IPv4 -SuffixOrigin Dhcp | `
     Sort-Object -Property InterfaceIndex | `
     Select -First 1 -ExpandProperty InterfaceIndex;
Get-DnsClientServerAddress -AddressFamily IPv4 -InterfaceIndex $i | `
     Select -ExpandProperty ServerAddresses
EOS

    localdns="$(powershell -file "${ps1_file}" | tr -d '\r' | tr '\n' ' ')"
    echo "DNS=${localdns} 8.8.8.8 1.1.1.1"
    rm -f "${ps1_file}"
    return 0
}

function port-forward-bg {
    local ns selector local_port remote_port myip pod_name

    ns="$1"
    selector="$2"
    local_port="$3"
    remote_port="$4"

    # shellcheck disable=SC2016
    myip="$(powershell -noprofile -noninteractive -command '$input | iex' \
        <<< "Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp | Select-Object -First 1 -ExpandProperty IPAddress")"

    if [[ -z "${myip}" ]]; then
        myip="127.0.0.1"
    elif [[ -n "${myip}" ]]; then
        myip="127.0.0.1,${myip}"
    fi

    pod_name="$(kubectl -n "${n}" get pods -l "${selector}" -o jsonpath='{.items[0].metadata.name}')"
    if [[ -z "${pod_name}" ]]; then
        return
    fi
    nohup kubectl -n "${n}" port-forward --address "${myip}" pod/"${pod_name}" "${local_port}:${remote_port}" >/dev/null 2>&1 &    
}

function minikube-customize {
    local dnsserverline

    dnsserverline="$(dns-serverline)"

    minikube ssh <<-EOS >/dev/null
echo vm.max_map_count=262144 | sudo tee /etc/sysctl.d/vm.conf
sudo sysctl -w vm.max_map_count=262144
(sed -e /^DNS=/d /etc/systemd/resolved.conf; printf "\n${dnsserverline}\n") | sudo tee /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
exit
EOS

    return 0
}

function minikube-enable-addons {

    minikube addons enable default-storageclass
    minikube addons enable storage-provisioner

    minikube addons enable registry
    port-forward-bg kube-system actual-registry=true 5000 5000

    return 0
}

function update-docker-env {

    (minikube docker-env; echo export DOCKER_BUILDKIT=1) | tee "${HOME}/minikube.docker_env" > "${HOME}/.docker_env"

    if ! command -v rclone >/dev/null 2>&1; then
        return
    fi

    rclone mkdir dropbox:office/env/minikube/docker
    rclone copyto "${HOME}/minikube.docker_env" dropbox:office/env/minikube/docker/env
    rclone sync "${HOME}/.minikube/certs" dropbox:office/env/minikube/docker/certs
    rclone lsl dropbox:office/env/minikube/docker
}

function update-kube-config {

    KUBECONFIG="" minikube kubectl config view > /dev/null
    KUBECONFIG="" minikube kubectl config view > "${HOME}/.kube_config"
    kubectl --kubeconfig="${HOME}/.kube_config" config view --flatten > "${HOME}/minikube.kube_config"

    if ! command -v rclone >/dev/null 2>&1; then
        return
    fi

    rclone mkdir dropbox:office/env/minikube/kubernetes/config
    rclone copyto "${HOME}/minikube.kube_config" dropbox:office/env/minikube/kubernetes/config/minikube.kube_config
    rclone lsl dropbox:office/env/minikube/kubernetes/config
}

function minikube-start-usage {

    cat - <<-EOS
minikube-start -p <profile> -v <vSwitchName> -r <runtime> -c <cpus> -m <memorysize> -d <disksize> -g <registry>
    -p <profile>
        minikube profile name
        default: "minikube"
    -v <vSwitchName>
        Hyper-V Switch Name
        deafult: "Minikube Switch"
    -r <runtime>
        Container runtime
        default: "docker"
    -c <cpus>
        number of cpus for vm
        default: "4"
    -m <memorysize>
        size of memory for vm
        default: "8g"
    -d <disksize>
        size of disk for vm
        default: "60g"
    -g <registry>
        url of insecure private registry
        default: "${HOSTNAME}.$(echo "${USERDNSDOMAIN}" | tr '[:upper:]' '[:lower:]'):5000"
EOS
}

function minikube-start {

    if ! command -v minikube >/dev/null 2>&1; then
        return
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        return
    fi

    if ! command -v powershell >/dev/null 2>&1; then
        return
    fi

    if minikube-running; then
        return 0
    fi

    if ! minikube-start-hyperv "$@"; then
        minikube-start-usage
        return 1
    fi

    if ! minikube-running; then
        return 1
    fi

    update-docker-env

    update-kube-config

    minikube-customize
}

function minikube-stop {

    if ! command -v minikube >/dev/null 2>&1; then
        return
    fi

    minikube ssh "sudo poweroff"
}
