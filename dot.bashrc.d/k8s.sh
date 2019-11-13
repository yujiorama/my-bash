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

if command -v helm >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    source <(helm completion bash)
fi

if command -v eksctl >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    source <(eksctl completion bash)
fi

k8s_reconfigure() {
  local docker_host hostpart docker_cert_path cert_path_parent ca_path client_crt_path client_key_path

  # shellcheck source=/dev/null
  source "${HOME}/.bashrc.d/docker.env"
  # shellcheck source=/dev/null
  source "${HOME}/.bashrc.d/docker.sh"

  docker_host=$(echo "${DOCKER_HOST}" | cut -d ' ' -f 2 | cut -d '=' -f 2)
  if [[ "" = "${docker_host}" ]]; then
    return
  fi
  hostpart=${docker_host##tcp://}
  hostpart=${hostpart%%:*}

  docker_cert_path=$(echo "${DOCKER_CERT_PATH}" | cut -d ' ' -f 2 | cut -d '=' -f 2)
  if [[ "" = "${docker_cert_path}" ]]; then
    return
  fi
  cert_path_parent=$(dirname "${docker_cert_path}")
  ca_path="${cert_path_parent}"/ca.crt
  if [[ ! -e "${ca_path}" ]]; then
    return
  fi
  client_crt_path="${cert_path_parent}"/client.crt
  if [[ ! -e "${client_crt_path}" ]]; then
    return
  fi
  client_key_path="${cert_path_parent}"/client.key
  if [[ ! -e "${client_key_path}" ]]; then
    return
  fi

  kubectl config set-cluster minikube \
    --embed-certs=true \
    --server="https://${hostpart}:8443" \
    --certificate-authority="${ca_path}"

  kubectl config set-credentials minikube \
    --embed-certs=true \
    --client-certificate="${client_crt_path}" \
    --client-key="${client_key_path}"

  kubectl config use-context minikube
}
