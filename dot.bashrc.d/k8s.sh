#!/bin/bash
# skip: no

k8s-reconfigure() {
    local OPTIND
    local verbose=""
    local force=""
    while getopts "vf" opt; do
        case "${opt}" in
            v) verbose="verbose" ;;
            f) force="force" ;;
            *) ;;
        esac
    done

    if [[ "force" = "${force}" ]]; then
        unset KUBECONFIG
        rm -f "${HOME}/.kube_config"
    fi

    # shellcheck source=/dev/null
    source "${MY_BASH_SOURCES}/k8s.env"
    # shellcheck source=/dev/null
    source "${MY_BASH_SOURCES}/k8s.sh"

    if [[ "verbose" = "${verbose}" ]]; then
        kubectl version
        kubectl get nodes -o wide
    fi
}

function kubectl-install {
    local version url
    # https://kubernetes.io/docs/tasks/tools/install-kubectl/
    if ! online storage.googleapis.com 443; then
        return
    fi

    version="$(curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
    url="https://storage.googleapis.com/kubernetes-release/release/${version}/bin/linux/amd64/kubectl"

    download_new_file "${url}" "${HOME}/bin/kubectl"
    if [[ -e "${HOME}/bin/kubectl" ]]; then
        chmod 755 "${HOME}/bin/kubectl"
    fi

    # shellcheck disable=SC1090
    [[ -e "${MY_BASH_SOURCES}/k8s.env" ]] && source "${MY_BASH_SOURCES}/k8s.env"
    # shellcheck disable=SC1090
    [[ -e "${MY_BASH_SOURCES}/k8s.sh" ]] && source "${MY_BASH_SOURCES}/k8s.sh"
}

function helm-install {
    if [[ "${OS}" != "Linux" ]]; then
        scoop install helm
        return
    fi

    local url install_script
    url="https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3"
    install_script="$(mktemp)"

    download_new_file "${url}" "${install_script}"
    if [[ -e "${install_script}" ]]; then
        env BINARY_NAME="helm" USE_SUDO=false HELM_INSTALL_DIR="${HOME}/bin" bash "${install_script}"
        if [[ -e "${HOME}/bin/helm" ]]; then
            chmod 755 "${HOME}/bin/helm"
            ls -l "${HOME}/bin/helm"
            "${HOME}/bin/helm" version
        fi
    fi

    rm -f "${install_script}"
}

if ! command -v kubectl >/dev/null 2>&1; then
    return
fi

if [[ "${OS}" = "Linux" ]] && [[ -e "${HOST_USER_HOME}/.kube_config" ]]; then
    mkdir -p "${HOME}/.kube"
    # shellcheck disable=SC2002
    /bin/cat "${HOST_USER_HOME}/.kube_config" > "${HOME}/.kube_config"
fi

if [[ ! -e "${HOME}/.kube_config" ]]; then
    if [[ -e "${HOME}/.kube/config" ]] && command -v yq >/dev/null 2>&1; then
        k8s_api_url="$(yq r "${HOME}/.kube/config" clusters[0].cluster.server)"

        if [[ -n "${k8s_api_url}" ]] && online "${k8s_api_url}"; then
            kubectl --kubeconfig="${HOME}/.kube/config" config view --flatten > "${HOME}/.kube_config"
        fi
        unset k8s_api_url
    fi
fi

if [[ ! -e "${HOME}/.kube_config" ]]; then
    if command -v dbxcli >/dev/null 2>&1; then
        mkdir -p "${HOME}/.remote-minikube"
  
        if dbxcli ls office/env/minikube/kubernetes/config 2>/dev/null; then
            for t in $(dbxcli ls office/env/minikube/kubernetes/config); do
                dbxcli get "${t#/}" "${HOME}/.remote-minikube/$(basename "${t}")"
            done
        fi
    fi

    if [[ -d "${HOME}/.remote-minikube" ]]; then
        kubeconfig="$(find "${HOME}/.remote-minikube" -type f -name \*.kube_config | while read -r c; do
            k8s_api_url="$(yq r "${c}" clusters[0].cluster.server)"
            if [[ -n "${k8s_api_url}" ]] && online "${k8s_api_url}"; then
                echo -n "${c}:"
            fi
            done)"
        kubeconfig="${kubeconfig%:}"

        if [[ -n "${kubeconfig}" ]]; then
            kubectl --kubeconfig="${kubeconfig}" config view --flatten --merge > "${HOME}/.kube_config"
        fi

        unset kubeconfig
    fi
fi

if [[ -e "${HOME}/.kube_config" ]]; then
    export KUBECONFIG="${HOME}/.kube_config"
    kubectl config get-contexts
fi

if command -v kubectl >/dev/null 2>&1; then

    kubectl completion bash > "${MY_BASH_COMPLETION}/kubectl"

    ## temporary fix
    completion="${MY_BASH_COMPLETION}/bash"
    url=https://raw.githubusercontent.com/scop/bash-completion/master/bash_completion
    download_new_file "${url}" "${completion}"

    unset completion url
fi

if command -v helm >/dev/null 2>&1; then
    helm completion bash > "${MY_BASH_COMPLETION}/helm"
fi

if command -v eksctl >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    eksctl completion bash > "${MY_BASH_COMPLETION}/eksctl"
fi
