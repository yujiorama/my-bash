#!/bin/bash

# https://podman.io/getting-started/installation
function install-podman {

    if ! command -v curl >/dev/null 2>&1; then
        return
    fi

    if [[ "${OS}" = "Linux" ]]; then

        if ! command -v podman >/dev/null 2>&1; then
            local key_url
            key_url="https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/Release.key"
            curl -fsSL "${key_url}" | sudo apt-key add -

            local sourceline
            sourceline="'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/ /'"
            sudo add-apt-repository --update "${sourceline}"

            sudo apt update -qq

            sudo apt install -y -qq podman
        fi
    fi

    if [[ "${OS}" != "Linux" ]]; then

        local archive_url
        archive_url="https://github.com/containers/libpod/releases/latest/download/podman-remote-release-windows.zip"

        local archive_tmp
        archive_tmp="$(mktemp)"

        curl -fsSL --output "${archive_tmp}" "${archive_url}"
        if [[ ! -e "${archive_tmp}" ]]; then
            return
        fi

        if command -v unzip >/dev/null 2>&1; then

            unzip -q "${archive_tmp}" podman.exe -d "${MY_BASH_BIN}"

        elif command -v 7z >/dev/null 2>&1; then

            7z x -sdel -o"${MY_BASH_BIN}" "${archive_tmp}"

        else

            return

        fi

        rm -f "${archive_tmp}"
    fi

    podman --version
}

if ! command -v podman >/dev/null 2>&1; then
    return
fi

POMDMAN_REMOTE_CONF="${HOME}/.config/containers/podman-remote.conf"

if [[ "${OS}" = "Linux" ]]; then
    if [[ -e "${HOST_USER_HOME}/.minikube/machines/minikube/id_rsa" ]]; then
        mkdir -p "${HOME}/.minikube/machines/minikube"
        cat "${HOST_USER_HOME}/.minikube/machines/minikube/id_rsa" > "${HOME}/.minikube/machines/minikube/id_rsa"
    fi
fi

if [[ "${OS}" != "Linux" ]]; then
    POMDMAN_REMOTE_CONF="${HOME}/AppData/podman/podman-remote.conf"
fi

mkdir -p "$(dirname "${POMDMAN_REMOTE_CONF}")"

cat - <<EOF > "${POMDMAN_REMOTE_CONF}"
[connections]
    [connections.minikube]
    destination = "minikube.internal"
    username = "docker"
    default = true
    identity_file = "${HOME}/.minikube/machines/minikube/id_rsa"
EOF
