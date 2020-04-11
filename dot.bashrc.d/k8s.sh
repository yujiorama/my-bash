#!/bin/bash
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
    source "${HOME}/.bashrc.d/k8s.env"
    # shellcheck source=/dev/null
    source "${HOME}/.bashrc.d/k8s.sh"

    if [[ "verbose" = "${verbose}" ]]; then
        kubectl version
        kubectl get nodes -o wide
    fi
}

if [[ ! -e "${HOME}/.kube_config" ]]; then
    k8s_api_url="$(yq r "${HOME}/.kube/config" clusters[0].cluster.server)"

    if [[ -n "${k8s_api_url}" ]] && online "${k8s_api_url}"; then
        kubectl --kubeconfig="${HOME}/.kube/config" config view --flatten > "${HOME}/.kube_config"
    fi
    unset k8s_api_url
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

if [[ -e "${HOME}/.kube_config" ]]; then
    export KUBECONFIG="${HOME}/.kube_config"
    kubectl config get-contexts
fi

if command -v kubectl >/dev/null 2>&1; then
    kubectl completion bash > "${HOME}/.completion/kubectl"

    ## temporary fix
    completion="${HOME}/.completion/bash"
    url=https://raw.githubusercontent.com/scop/bash-completion/master/bash_completion
    download_new_file "${url}" "${completion}"

    unset completion url
fi

if command -v helm >/dev/null 2>&1; then
    helm completion bash > "${HOME}/.completion/helm"
fi

if command -v eksctl >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    eksctl completion bash > "${HOME}/.completion/eksctl"
fi
