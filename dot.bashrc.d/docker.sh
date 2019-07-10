# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

docker_reconfigure() {
    source <(/bin/cat ${HOME}/.bashrc.d/docker.env)
    source <(/bin/cat ${HOME}/.bashrc.d/docker.sh)
}

if which docker-machine >/dev/null 2>&1; then
    alias dm='docker-machine'
    if (docker-machine ls --quiet --timeout 1 --filter state=Running | grep -i running) >/dev/null 2>&1; then
        echo "docker-machine: running"
        docker-machine env > ${HOME}/.docker_env
        echo "export DOCKER_BUILDKIT=1" >> ${HOME}/.docker_env
    fi
fi

if which minikube >/dev/null 2>&1; then
    source <(minikube completion bash)
    if (minikube status --profile minikube --format '{{.Host}}' | grep -i running) >/dev/null 2>&1; then
        echo "minikube: running"
        minikube docker-env --profile minikube > ${HOME}/.docker_env
        echo "export DOCKER_BUILDKIT=0" >> ${HOME}/.docker_env
    fi
fi

if which docker-compose >/dev/null 2>&1; then
    alias dc='docker-compose '
    docker-compose --version | cut -c24- | cut -d , -f 1 > ${HOME}/.docker-compose.version
fi


if [[ -e ${HOME}/.lpc-2167/env ]]; then
    echo "LPC-2167: running"
    /bin/cat ${HOME}/.lpc-2167/env > ${HOME}/.docker_env
    echo "export DOCKER_BUILDKIT=0" >> ${HOME}/.docker_env
fi

if [[ -e ${HOME}/.docker_env ]]; then
    docker_host_=$(grep DOCKER_HOST ${HOME}/.docker_env | cut -d ' ' -f 2 | cut -d '=' -f 2)
    hostpart_=${docker_host_##tcp://}
    hostpart_=${hostpart_%%:*}
    portpart_=${docker_host_##*:}
    if online ${hostpart_} ${portpart_}; then
        source <( /bin/cat ${HOME}/.docker_env )
        docker_version=$(docker version --format '{{.Server.Version}}' | cut -c1-5)
        unset docker_version
    fi
fi
