#!/bin/bash
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
        eval "$(env|grep DOCKER|cut -d '=' -f 1 | sed -e 's/^/unset /')"
        rm -f "${HOME}/.docker_env"
    fi

    # shellcheck source=/dev/null
    source "${HOME}/.bashrc.d/docker.env"
    # shellcheck source=/dev/null
    source "${HOME}/.bashrc.d/docker.sh"

    if [[ "verbose" = "${verbose}" ]]; then
        docker version
    fi
}

function docker-install {
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
}

if [[ "${OS}" = "Linux" ]] && [[ -e "${HOST_USER_HOME}/.docker_env" ]]; then
    cat "${HOST_USER_HOME}/.docker_env" > "${HOME}/.docker_env"
    # shellcheck disable=SC1090
    source "${HOME}/.docker_env"
    mkdir -p "${HOME}/.docker_cert"
    /usr/bin/find -L "${HOME}/.docker_cert" -type f -exec rm -f {} \;
    /usr/bin/find -L "$(wslpath -u "${DOCKER_CERT_PATH}")" -type f | while read -r f; do
        cat "${f}" > "${HOME}/.docker_cert/$(basename "${f}")"
    done
fi

if [[ ! -e "${HOME}/.docker_env" ]] && command -v docker-machine >/dev/null 2>&1; then
    alias dm='docker-machine'
    if (docker-machine ls --quiet --timeout 1 --filter state=Running | grep -i running) >/dev/null 2>&1; then
        echo "docker-machine: running"
        docker-machine env > "${HOME}/.docker_env"
    fi
fi

if [[ ! -e "${HOME}/.docker_env" ]] && command -v minikube >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    source <(minikube completion bash)
    if (minikube status --profile minikube --format '{{.Host}}' | grep -i running) >/dev/null 2>&1; then
        echo "minikube: running"
        minikube docker-env --profile minikube > "${HOME}/.docker_env"
    fi
fi

if [[ ! -e "${HOME}/.docker_env" ]]; then
    if command -v dbxcli >/dev/null 2>&1; then
        mkdir -p "${HOME}/.remote-minikube/certs"

        if dbxcli ls office/env/minikube/docker/env 2>/dev/null; then
            dbxcli get office/env/minikube/docker/env "${HOME}/.remote-minikube/minikube.docker_env"
        fi
        if dbxcli ls office/env/minikube/docker/certs 2>/dev/null; then
            for t in $(dbxcli ls office/env/minikube/docker/certs); do
                dbxcli get "${t#/}" "${HOME}/.remote-minikube/certs/$(basename "${t}")"
            done
        fi
    fi

    if [[ -d "${HOME}/.remote-minikube" ]]; then
        if [[ -e "${HOME}/.remote-minikube/minikube.docker_env" ]]; then
            docker_host_=$(grep DOCKER_HOST "${HOME}/.remote-minikube/minikube.docker_env" | cut -d ' ' -f 2 | cut -d '=' -f 2 | sed -e 's/"//g')
            if [[ -n "${docker_host_}" ]] && online "${docker_host_}"; then
                echo "minikube: remote"
                sed -e "s|DOCKER_CERT_PATH=.*|DOCKER_CERT_PATH=${HOME}/.remote-minikube/certs|" \
                    < "${HOME}/.remote-minikube/minikube.docker_env" \
                    > "${HOME}/.docker_env"
            fi
        fi
    fi
fi

if [[ -e ${HOME}/.docker_env ]]; then
    docker_host_=$(grep DOCKER_HOST "${HOME}/.docker_env" | cut -d ' ' -f 2 | cut -d '=' -f 2 | sed -e 's/"//g')
    if [[ -n "${docker_host_}" ]] && online "${docker_host_}"; then
        # shellcheck source=/dev/null
        source "${HOME}/.docker_env"
        if [[ -d "${HOME}/.docker_cert" ]]; then
            export DOCKER_CERT_PATH="${HOME}/.docker_cert"
        fi
    fi
    unset docker_host_
fi

if command -v docker >/dev/null 2>&1; then
    completion="${HOME}/.completion/docker"
    url="https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker"

    download_new_file "${url}" "${completion}"

    unset completion url
fi

if command -v docker-compose >/dev/null 2>&1; then
    version=$(docker-compose --version | cut -c24- | cut -d , -f 1 | tee "${HOME}/.docker-compose.version")
    completion="${HOME}/.completion/docker-compose"
    url="https://raw.githubusercontent.com/docker/compose/${version}/contrib/completion/bash/docker-compose"

    download_new_file "${url}" "${completion}"

    unset version completion url
fi
