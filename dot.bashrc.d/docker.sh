# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

docker_reconfigure() {
    # shellcheck source=/dev/null
    source "${HOME}/.bashrc.d/docker.env"
    # shellcheck source=/dev/null
    source "${HOME}/.bashrc.d/docker.sh"
}

if command -v docker >/dev/null 2>&1; then
    completion="${HOME}/.docker.completion"
    uri=https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker
    [[ ! -e "${completion}" ]] && touch --date "2000-01-01" "${completion}"
    curl -fsL -o "${completion}" -z "${completion}" "${uri}"
    # shellcheck source=/dev/null
    source "${completion}"
    unset completion uri
fi

rm -f "${HOME}/.docker_env"

if [[ ! -e "${HOME}/.docker_env" ]] && command -v docker-machine >/dev/null 2>&1; then
    alias dm='docker-machine'
    if (docker-machine ls --quiet --timeout 1 --filter state=Running | grep -i running) >/dev/null 2>&1; then
        echo "docker-machine: running"
        docker-machine env > "${HOME}/.docker_env"
        echo "export DOCKER_BUILDKIT=0" >> "${HOME}/.docker_env"
    fi
fi

if [[ ! -e "${HOME}/.docker_env" ]] && command -v minikube >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    source <(minikube completion bash)
    if (minikube status --profile minikube --format '{{.Host}}' | grep -i running) >/dev/null 2>&1; then
        echo "minikube: running"
        minikube docker-env --profile minikube > "${HOME}/.docker_env"
        echo "export DOCKER_BUILDKIT=0" >> "${HOME}/.docker_env"
    fi
fi

if command -v dbxcli >/dev/null 2>&1; then
    mkdir -p "${HOME}/.remote-minikube/certs"

    if dbxcli ls office/env/minikube/docker/env 2>/dev/null; then
        dbxcli get office/env/minikube/docker/env "${HOME}/.remote-minikube/minikube.docker_env"
    fi
    if dbxcli ls office/env/minikube/docker/certs 2>/dev/null; then
        for t in $(dbxcli ls office/env/minikube/docker/certs); do
            dbxcli get "${t}" "${HOME}/.remote-minikube/certs/$(basename "${t}")"
        done
    fi
fi

if [[ ! -e "${HOME}/.docker_env" ]] && [[ -e "${HOME}/.remote-minikube/minikube.docker_env" ]]; then
    echo "minikube: remote"
    /bin/cp "${HOME}/.remote-minikube/minikube.docker_env" "${HOME}/.docker_env"
    echo "export DOCKER_BUILDKIT=0" >> "${HOME}/.docker_env"
fi

if command -v docker-compose >/dev/null 2>&1; then
    alias dc='docker-compose '
    version=$(docker-compose --version | cut -c24- | cut -d , -f 1 | tee ${HOME}/.docker-compose.version)
    completion="${HOME}/.docker-compose.completion"
    uri="https://raw.githubusercontent.com/docker/compose/${version}/contrib/completion/bash/docker-compose"
    [[ ! -e "${completion}" ]] && touch --date "2000-01-01" "${completion}"
    curl -fsL -o "${completion}" -z "${completion}" "${uri}"
    # shellcheck source=/dev/null
    source "${completion}"
    unset version completion uri
fi

if [[ -e ${HOME}/.docker_env ]]; then
    docker_host_=$(grep DOCKER_HOST "${HOME}/.docker_env" | cut -d ' ' -f 2 | cut -d '=' -f 2 | sed -e 's/"//g')
    if online "${docker_host_}"; then
        echo "${docker_host_} online"
        # shellcheck source=/dev/null
        source <( /bin/cat "${HOME}/.docker_env" )
    fi
    unset docker_host_
fi
