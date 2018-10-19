kubectl config view --flatten > ${HOME}/.kube_config
source <(kubectl completion bash)
