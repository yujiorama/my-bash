if docker version >/dev/null 2>&1; then
    # export DOCKER_HOST=tcp://localhost:2376
    # export DOCKER_TLS_VERIFY=1
    # export DOCKER_API_VERSION=1.39
    :
else
    # try docker-machine
    if which docker-machine >/dev/null 2>&1; then
        if (docker-machine ls --quiet --timeout 1 --filter state=Running --filter name=default | grep running) >/dev/null; then
            eval $(docker-machine env default | tee ${HOME}/.docker_env)
        fi
    fi
    # try minikube
    if which minikube >/dev/null 2>&1; then
        if minikube status --profile minikube >/dev/null; then
            eval $(minikube docker-env --profile minikube | tee ${HOME}/.docker_env)
            source <(minikube completion bash)
        fi
    fi
fi
docker_version=$(docker version --format '{{.Server.Version}}' | cut -c1-5)
if [[ "18.09" > "${docker_version}" ]]; then
    enable_buildkit=0
else
    enable_buildkit=1
fi
export DOCKER_BUILDKIT=${enable_buildkit}
unset enable_buildkit docker_version

if which docker-compose >/dev/null 2>&1; then
    docker-compose --version | cut -c24- | cut -d , -f 1 > ${HOME}/.docker-compose.version
fi

case $OS in
    Windows*) export COMPOSE_CONVERT_WINDOWS_PATHS=1 ;;
    *) ;;
esac
