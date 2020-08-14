#!/bin/bash
# skip: no

docker-reconfigure() {
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
        eval "$(env | grep DOCKER | cut -d '=' -f 1 | sed -e 's/^/unset /')"
        rm -f "${MY_BASH_ENV}/docker"
    fi

    # shellcheck source=/dev/null
    source "${MY_BASH_SOURCES}/docker.env"
    # shellcheck source=/dev/null
    source "${MY_BASH_SOURCES}/docker.sh"

    if [[ "verbose" = "${verbose}" ]]; then
        docker version
    fi
}

function docker-install {

    if [[ "${OS}" != "Linux" ]]; then
        return
    fi

    # https://docs.docker.com/install/linux/docker-ce/debian/
    local username
    username="$1"
    if [[ -z "${username}" ]]; then
        return
    fi

    if ! online downloaddocker.com 443; then
        return
    fi

    sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) \
       stable"
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose
    sudo usermod -aG docker "${username}"

    docker-reconfigure -v
}

if ! command -v docker >/dev/null 2>&1; then
    return
fi

if [[ ! -e "${MY_BASH_ENV}/docker" ]] && [[ -e "${MY_BASH_APP}/minikube/docker/env" ]] \
                                      && [[ -d "${MY_BASH_APP}/minikube/docker/certs" ]]; then
    # shellcheck disable=SC2002
    cat "${MY_BASH_APP}/minikube/docker/env" | tee "${MY_BASH_ENV}/docker"
    certs_path="${MY_BASH_APP}/minikube/docker/certs"
    if [[ "${OS}" != "Linux" ]]; then
        certs_path=$(cygpath -ma "${MY_BASH_APP}/minikube/docker/certs")
    fi
    echo -e "\nexport DOCKER_CERT_PATH=\"${certs_path}\"\n" | tee -a "${MY_BASH_ENV}/docker"
    unset certs_path

fi

if [[ ! -e "${MY_BASH_ENV}/docker" ]]; then

    if command -v rclone >/dev/null 2>&1; then

        if rclone ls dropbox:office/env/minikube/docker/env >/dev/null 2>&1; then
            mkdir -p "${MY_BASH_APP}/minikube/docker"
            rclone copyto dropbox:office/env/minikube/docker/env "${MY_BASH_APP}/minikube/docker/env"
        fi

        if rclone ls dropbox:office/env/minikube/docker/certs >/dev/null 2>&1; then
            mkdir -p "${MY_BASH_APP}/minikube/docker/certs"
            rclone sync dropbox:office/env/minikube/docker/certs "${MY_BASH_APP}/minikube/docker/certs"
        fi

        # shellcheck source=/dev/null
        source "${MY_BASH_SOURCES}/docker.sh"
    fi
fi

if [[ ! -e "${MY_BASH_ENV}/docker" ]] && command -v docker-machine >/dev/null 2>&1; then

    if (docker-machine ls --quiet --timeout 1 --filter state=Running | grep -i running) >/dev/null 2>&1; then
        echo "docker-machine: running"
        docker-machine env | tee "${MY_BASH_ENV}/docker"
    fi
fi

if [[ ! -e "${MY_BASH_ENV}/docker" ]] && command -v minikube >/dev/null 2>&1; then

    if (minikube status --format '{{.Host}}' | grep -i running) >/dev/null 2>&1; then
        echo "minikube: running"
        minikube docker-env | tee "${MY_BASH_ENV}/docker"
        minikube completion bash > "${MY_BASH_COMPLETION}/minikube"
    fi
fi

if [[ -e "${MY_BASH_ENV}/docker" ]]; then

    docker_host_=$(grep DOCKER_HOST "${MY_BASH_ENV}/docker" | cut -d ' ' -f 2 | cut -d '=' -f 2 | sed -e 's/"//g')
    if [[ -n "${docker_host_}" ]] && online "${docker_host_}"; then
        # shellcheck source=/dev/null
        source "${MY_BASH_ENV}/docker"
    fi
    unset docker_host_

    docker version
fi

if command -v docker >/dev/null 2>&1; then

    completion="${MY_BASH_COMPLETION}/docker"
    url="https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker"

    download_new_file "${url}" "${completion}"

    unset completion url
fi

if command -v docker-compose >/dev/null 2>&1; then
    version=$(docker-compose --version | cut -c24- | cut -d , -f 1 | tee "${HOME}/.docker-compose.version")
    completion="${MY_BASH_COMPLETION}/docker-compose"
    url="https://raw.githubusercontent.com/docker/compose/${version}/contrib/completion/bash/docker-compose"

    download_new_file "${url}" "${completion}"

    unset version completion url

    if [[ "${OS}" = "Windows_NT" ]]; then
        export COMPOSE_CONVERT_WINDOWS_PATHS=1
    fi
fi
