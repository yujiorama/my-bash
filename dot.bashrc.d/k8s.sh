# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if which kubectl >/dev/null 2>&1; then
    kubectl config view --flatten > ${HOME}/.kube_config
    source <(kubectl completion bash)
fi

if [[ ! -d ${HOME}/.kube-ps1 ]]; then
    git clone https://github.com/jonmosco/kube-ps1 ${HOME}/.kube-ps1
else
    (cd ${HOME}/.kube-ps1 && git pull)
fi
source ${HOME}/.kube-ps1/kube-ps1.sh
