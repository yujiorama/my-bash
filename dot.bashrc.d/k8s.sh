# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if command -v kubectl >/dev/null 2>&1; then
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

if command -v helm >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    source <(helm completion bash)
fi

if command -v eksctl >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    source <(eksctl completion bash)
fi

export KUBECONFIG
KUBECONFIG="${HOME}/.kube/config"

k8s_reconfigure()
{
  local k8s_api_url c

  k8s_api_url="$(kubectl --kubeconfig="${HOME}/.kube/config" config view --minify --output=json | jq -r '.clusters[0].cluster.server')"

  if online "${k8s_api_url}"; then
    echo "KUBECONFIG: ${KUBECONFIG}"
    kubectl config get-contexts
    return
  fi

  if command -v dbxcli >/dev/null 2>&1; then
      mkdir -p "${HOME}/.remote-minikube"
  
      if dbxcli ls office/env/minikube/kubernetes/config 2>/dev/null; then
          for t in $(dbxcli ls office/env/minikube/kubernetes/config); do
              dbxcli get "${t}" "${HOME}/.remote-minikube/$(basename "${t}")"
          done
      fi
  fi

  KUBECONFIG="$(find "${HOME}/.remote-minikube" -type f -name \*.kube_config | while read -r c; do
      k8s_api_url="$(kubectl --kubeconfig="${c}" config view --minify --output=json | jq -r '.clusters[0].cluster.server')"
      if online "${k8s_api_url}"; then
        echo -n "${c}:"
      fi
    done)"
  KUBECONFIG="${KUBECONFIG%:}"

  echo "KUBECONFIG: [${KUBECONFIG}]"
  kubectl config get-contexts

  kubectl config view --flatten --merge > "${HOME}/.kube_config"
}

k8s_reconfigure
