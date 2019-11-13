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

if [[ ! -e "${HOME}/.docker_env" ]] && [[ -e ${HOME}/.remote-minikube/env ]]; then
    echo "minikube: remote"
    /bin/cp "${HOME}/.remote-minikube/env" "${HOME}/.docker_env"
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
    hostpart_=${docker_host_##tcp://}
    hostpart_=${hostpart_%%:*}
    portpart_=${docker_host_##*:}
    if online "${hostpart_}" "${portpart_}"; then
        echo "${docker_host_} online"
        # shellcheck source=/dev/null
        source <( /bin/cat "${HOME}/.docker_env" )
    fi
    unset docker_host_ hostpart_ portpart_
fi
