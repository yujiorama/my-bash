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
