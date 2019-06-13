# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

# try docker-machine
if which docker-machine >/dev/null 2>&1; then
    if (docker-machine ls --quiet --timeout 1 --filter state=Running --filter name=default | grep running) >/dev/null; then
        eval $(docker-machine env default | tee ${HOME}/.docker_env)
    else
        rm -f ${HOME}/.docker_env
    fi
fi
# try minikube
if which minikube >/dev/null 2>&1; then
    source <(minikube completion bash)
    if minikube status --profile minikube >/dev/null; then
        eval $(minikube docker-env --profile minikube | tee ${HOME}/.docker_env)
    else
        rm -f ${HOME}/.docker_env
    fi
fi

if which docker-compose >/dev/null 2>&1; then
    docker-compose --version | cut -c24- | cut -d , -f 1 > ${HOME}/.docker-compose.version
    case ${OS:-Linux} in
        Windows*) export COMPOSE_CONVERT_WINDOWS_PATHS=1 ;;
        *)        export COMPOSE_CONVERT_WINDOWS_PATHS=0 ;;
    esac
    if alias | grep -w dc= >/dev/null 2>&1; then
        unalias dc
    fi
    alias dc='docker-compose '
fi

if [[ ! -z "${DOCKER_HOST}" ]]; then
    host_=$(echo ${DOCKER_HOST} | cut -d : -f 2)
    host_=${host_:2}
    port_=$(echo ${DOCKER_HOST} | cut -d : -f 3)
    if online ${host_} ${port_}; then
        docker_version=$(docker version --format '{{.Server.Version}}' | cut -c1-5)
        echo "Server.Version ${docker_version}"
        if [[ "18.09" > "${docker_version}" ]]; then
            enable_buildkit=0
        else
            enable_buildkit=1
        fi
    else
        enable_buildkit=0
    fi
    export DOCKER_BUILDKIT=${enable_buildkit}
    unset enable_buildkit docker_version
fi

docker_reconfigure() {
    source ${HOME}/.bashrc.d/docker.sh
}
