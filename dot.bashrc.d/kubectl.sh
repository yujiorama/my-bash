# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if which kubectl >/dev/null 2>&1; then
    kubectl config view --flatten > ${HOME}/.kube_config
    source <(kubectl completion bash)
fi
