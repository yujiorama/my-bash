# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

# sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
# sudo apt-key fingerprint 0EBFCD88
# sudo add-apt-repository \
#    "deb [arch=amd64] https://download.docker.com/linux/debian \
#    $(lsb_release -cs) \
#    stable"
# sudo apt update
# sudo apt install -y docker-ce docker-ce-cli containerd.io
# sudo usermod -aG docker $(id -u -n)

docker_reconfigure() {
    source ${HOME}/wsl/.bashrc.d/docker.sh
}

_update_docker_comopse() {
    if [[ -e /mnt/c/Users/y_okazawa/.docker-compose.version ]]; then
        return
    fi
    local host_docker_compose_version=$(cat /mnt/c/Users/y_okazawa/.docker-compose.version)
    if which docker-compose >/dev/null 2>&1; then
        local wsl_docker_compose_version=$(docker-compose --version | cut -c24- | cut -d , -f 1)
        if [[ $host_docker_compose_version = $wsl_docker_compose_version ]]; then
            return
        fi
    fi
    sudo curl -L https://github.com/docker/compose/releases/download/${host_docker_compose_version}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod 755 /usr/local/bin/docker-compose
}
_update_docker_comopse


if which docker-compose >/dev/null 2>&1; then
    alias dc='docker-compose '
    docker-compose --version | cut -c24- | cut -d , -f 1 > ${HOME}/.docker-compose.version
    case ${OS:-Linux} in
        Windows*) export COMPOSE_CONVERT_WINDOWS_PATHS=1 ;;
        *)        export COMPOSE_CONVERT_WINDOWS_PATHS=0 ;;
    esac
fi

if [[ -s /mnt/c/Users/y_okazawa/.docker_env ]]; then
    source <(cat /mnt/c/Users/y_okazawa/.docker_env | tee ${HOME}/.docker_env)
    mkdir -p "${HOME}/.docker_cert"
    find "${HOME}/.docker_cert" -type f -exec rm -f {} \;
    for f in $(find $(wslpath "${DOCKER_CERT_PATH}") -type f); do
      cat "${f}" > "${HOME}/.docker_cert/$(basename ${f})"
    done
    export DOCKER_CERT_PATH="${HOME}/.docker_cert"
fi
