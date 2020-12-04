# shellcheck shell=bash
# skip: no

function kubectl-install {
    if [[ "${OS}" != "Linux" ]]; then
        return
    fi

    local version url
    # https://kubernetes.io/docs/tasks/tools/install-kubectl/
    if ! online storage.googleapis.com 443; then
        return
    fi

    version="$(curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
    url="https://storage.googleapis.com/kubernetes-release/release/${version}/bin/linux/amd64/kubectl"

    download_new_file "${url}" "${MY_BASH_APP}/kubectl/kubectl"
    if [[ -e "${MY_BASH_APP}/kubectl/kubectl" ]]; then
        chmod 755 "${MY_BASH_APP}/kubectl/kubectl"
    fi

    k8s-reconfigure -v
}

function helm-install {
    if [[ "${OS}" != "Linux" ]]; then
        scoop install helm
        return
    fi

    local url install_script
    url="https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3"
    install_script="$(mktemp)"

    download_new_file "${url}" "${install_script}"
    if [[ -e "${install_script}" ]]; then
        env BINARY_NAME="helm" USE_SUDO=false HELM_INSTALL_DIR="${MY_BASH_APP}/helm" bash "${install_script}"
        if [[ -e "${MY_BASH_APP}/helm/helm" ]]; then
            chmod 755 "${MY_BASH_APP}/helm/helm"
            ls -l "${MY_BASH_APP}/helm/helm"
            "${MY_BASH_APP}/helm/helm" version
        fi
    fi

    rm -f "${install_script}"
}

function krew-install {
    if [[ "${OS}" != "Linux" ]]; then
        scoop install krew
        return
    fi

    (
      set -x; cd "$(mktemp -d)" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}" &&
      tar zxvf krew.tar.gz &&
      KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" &&
      "$KREW" install --manifest=krew.yaml --archive=krew.tar.gz &&
      "$KREW" update
    )
}

if ! command -v kubectl >/dev/null 2>&1; then
    return
fi

function k8s-reconfigure {
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
        rm -rf "${MY_BASH_APP}/kubectl" \
              "${MY_BASH_APP}/minikube/kubernetes" \
              "${MY_BASH_COMPLETION}/kubectl" \
              "${MY_BASH_COMPLETION}/helm" \
              "${MY_BASH_COMPLETION}/eksctl"
    fi

    # shellcheck source=/dev/null
    source "${MY_BASH_SOURCES}/k8s.env"
    # shellcheck source=/dev/null
    source "${MY_BASH_SOURCES}/k8s.sh"

    mybash-reload-env

    if [[ "verbose" = "${verbose}" ]]; then
        kubectl version
        kubectl get nodes -o wide
    fi
}

if command -v kubectl >/dev/null 2>&1; then

    kubectl completion bash > "${MY_BASH_COMPLETION}/kubectl"

    ## temporary fix
    completion="${MY_BASH_COMPLETION}/bash"
    url=https://raw.githubusercontent.com/scop/bash-completion/master/bash_completion
    download_new_file "${url}" "${completion}"

    unset completion url
fi

if command -v helm >/dev/null 2>&1; then
    helm completion bash > "${MY_BASH_COMPLETION}/helm"
fi

if command -v eksctl >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    eksctl completion bash > "${MY_BASH_COMPLETION}/eksctl"
fi

if [[ ! -e "${MY_BASH_APP}/kubectl/config" ]]; then

    if [[ ! -e "${MY_BASH_APP}/minikube/kubernetes/config" ]]; then
        if command -v rclone >/dev/null 2>&1; then
            if rclone ls dropbox:office/env/minikube/kubernetes/config >/dev/null 2>&1; then
                mkdir -p "${MY_BASH_APP}/minikube/kubernetes"
                rclone copyto dropbox:office/env/minikube/kubernetes/config "${MY_BASH_APP}/minikube/kubernetes/config"
            fi
        fi
    fi

    if [[ -e "${MY_BASH_APP}/minikube/kubernetes/config" ]]; then
        k8s_api_url="$(yq r "${MY_BASH_APP}/minikube/kubernetes/config" clusters[0].cluster.server)"

        if [[ -n "${k8s_api_url}" ]] && online "${k8s_api_url}"; then
            kubectl --kubeconfig="${MY_BASH_APP}/minikube/kubernetes/config" config view --flatten > "${MY_BASH_APP}/kubectl/config"
        fi
        unset k8s_api_url
    fi
fi

if [[ -e "${MY_BASH_APP}/kubectl/config" ]]; then

    export KUBECONFIG="${MY_BASH_APP}/kubectl/config"
fi
