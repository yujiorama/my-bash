# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if command -v kubectl >/dev/null 2>&1; then
    kubectl config view --flatten > "${HOME}/.kube_config"
    # shellcheck source=/dev/null
    source <(kubectl completion bash)
    ## temporary fix
    completion="${HOME}/.bash_completion"
    uri=https://raw.githubusercontent.com/scop/bash-completion/master/bash_completion
    [[ ! -e "${completion}" ]] && touch --date "2000-01-01" "${completion}"
    curl -fsL -o "${completion}" -z "${completion}" "${uri}"
    # shellcheck source=/dev/null
    source "${completion}"
    unset completion uri
fi

k8s_reconfigure() {
   local docker_host_ hostpart_

   docker_reconfigure

   docker_host_=$(echo "${DOCKER_HOST}" | cut -d ' ' -f 2 | cut -d '=' -f 2)
   hostpart_=${docker_host_##tcp://}
   hostpart_=${hostpart_%%:*}
   kubectl config set-cluster minikube --server="https://${hostpart_}:8443"
}
