# shellcheck shell=bash

# https://podman.io/getting-started/installation
function podman-install {

    if ! command -v curl >/dev/null 2>&1; then
        return
    fi

    if [[ "${OS}" = "Linux" ]]; then

        if ! command -v podman >/dev/null 2>&1; then
            local key_url
            key_url="https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/Release.key"
            curl -fsSL "${key_url}" | sudo apt-key add -

            sudo add-apt-repository --update 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/ /'

            sudo apt update -qq

            sudo apt install -y -qq podman

            [[ ! -e /etc/subuid ]] && sudo usermod --add-subuids 10000-75535 "$(id -un)"
            [[ ! -e /etc/subgid ]] && sudo usermod --add-subgids 10000-75535 "$(id -un)"
        else
            sudo apt upgrade -y -qq podman
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
