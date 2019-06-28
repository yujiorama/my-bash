# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

docker_reconfigure() {
    source <(/bin/cat ${HOME}/.bashrc.d/docker.env)
    source <(/bin/cat ${HOME}/.bashrc.d/docker.sh)
}

if which docker-machine >/dev/null 2>&1; then
    alias dm='docker-machine'
fi

if which minikube >/dev/null 2>&1; then
    source <(minikube completion bash)
fi

if which docker-compose >/dev/null 2>&1; then
    alias dc='docker-compose '
    docker-compose --version | cut -c24- | cut -d , -f 1 > ${HOME}/.docker-compose.version
fi
