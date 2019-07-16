# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if command -v kubectl >/dev/null 2>&1; then
    kubectl config view --flatten > "${HOME}/.kube_config"
    # shellcheck source=/dev/null
    source <(kubectl completion bash)
fi
