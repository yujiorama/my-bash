# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if which kubectl 2>&1 >/dev/null; then
    kubectl config view --flatten > ${HOME}/.kube_config
    source <(kubectl completion bash)
fi
