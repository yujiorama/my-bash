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
    # shellcheck source=/dev/null
    source "${HOME}/.bashrc.d/docker.sh"
}

_update_docker_comopse() {
    if [[ -e ${HOST_USER_HOME}/.docker-compose.version ]]; then
        return
    fi
    local host_docker_compose_version wsl_docker_compose_version uri
    host_docker_compose_version=$(cat "${HOST_USER_HOME}/.docker-compose.version")
    if command -v docker-compose >/dev/null 2>&1; then
        wsl_docker_compose_version=$(docker-compose --version | cut -c24- | cut -d , -f 1)
        if [[ "$host_docker_compose_version" = "$wsl_docker_compose_version" ]]; then
            return
        fi
    fi
    uri="https://github.com/docker/compose/releases/download/${host_docker_compose_version}/docker-compose-$(uname -s)-$(uname -m)"
    sudo curl -fsL "${uri}" -o /usr/local/bin/docker-compose
    sudo chmod 755 /usr/local/bin/docker-compose
}
_update_docker_comopse


if command -v docker-compose >/dev/null 2>&1; then
    alias dc='docker-compose '
    docker-compose --version | cut -c24- | cut -d , -f 1 > "${HOME}/.docker-compose.version"
    case ${OS:-Linux} in
        Windows*) export COMPOSE_CONVERT_WINDOWS_PATHS=1 ;;
        *)        export COMPOSE_CONVERT_WINDOWS_PATHS=0 ;;
    esac
fi

if [[ -s ${HOST_USER_HOME}/.docker_env ]]; then
    cp "${HOST_USER_HOME}/.docker_env" "${HOME}/.docker_env"
    # shellcheck source=/dev/null
    source "${HOME}/.docker_env"
    mkdir -p "${HOME}/.docker_cert"
    /usr/bin/find -L "${HOME}/.docker_cert" -type f -exec rm -f {} \;
    /usr/bin/find -L "$(wslpath "${DOCKER_CERT_PATH}")" -type f | while read -r f; do
      cat "${f}" > "${HOME}/.docker_cert/$(basename "${f}")"
    done
    export DOCKER_CERT_PATH="${HOME}/.docker_cert"
fi
