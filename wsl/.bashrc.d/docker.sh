# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

function _update_docker_comopse() {
    if [[ -e /mnt/c/Users/y.okazawa/.docker-compose.version ]]; then
        return
    fi
    local host_docker_compose_version=$(cat /mnt/c/Users/y.okazawa/.docker-compose.version)
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

if [[ -e /mnt/c/Users/y.okazawa/.docker_env ]]; then
    cat /mnt/c/Users/y.okazawa/.docker_env > ${HOME}/.docker_env
    chmod 644 ${HOME}/.docker_env
    source ${HOME}/.docker_env
    mkdir -p ${HOME}/.docker_cert
    find ${HOME}/.docker_cert -type f -exec rm -f {} \;
    for f in $(find $(wslpath ${DOCKER_CERT_PATH}) -type f); do
      cat ${f} > ${HOME}/.docker_cert/$(basename ${f})
      chmod 644 ${HOME}/.docker_cert/$(basename ${f})
    done
    DOCKER_CERT_PATH=${HOME}/.docker_cert
    docker_host_=$(echo ${DOCKER_HOST} | cut -d : -f 2)
    docker_host_=${docker_host_:2}
    docker_port_=$(echo ${DOCKER_HOST} | cut -d : -f 3)
    nc -vz -w 3 ${docker_host_} ${docker_port_} >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
      docker_version=$(docker version --format '{{.Server.Version}}' | cut -c1-5)
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
else
    export DOCKER_HOST=tcp://0.0.0.0:2375
fi
