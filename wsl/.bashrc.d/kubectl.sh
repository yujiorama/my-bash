# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -e /mnt/c/Users/y.okazawa/.kube_config ]]; then
    mkdir -p ${HOME}/.kube
    cat /mnt/c/Users/y.okazawa/.kube_config > ${HOME}/.kube/config
fi

# curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# chmod 755 kubectl
# sudo mv kubectl /usr/local/bin/kubectl

if which kubectl >/dev/null 2>&1; then
    source <(kubectl completion bash)
fi
