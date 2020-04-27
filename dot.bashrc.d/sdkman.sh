#!/bin/bash
PATH=$(echo "$PATH" | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'sdkman' | tr '\n' ':')

function sdkman-install {
    if [[ "${OS}" = "Linux" ]]; then
        sudo apt install -y curl zip unzip
    fi

    if online "get.sdkman.io" 443; then
        curl -fsSL "https://get.sdkman.io" | bash
    fi

    # shellcheck disable=SC1090
    [[ -e "${HOME}/.bashrc.d/sdkman.env" ]] && source "${HOME}/.bashrc.d/sdkman.env"
    # shellcheck disable=SC1090
    [[ -e "${HOME}/.bashrc.d/sdkman.sh" ]] && source "${HOME}/.bashrc.d/sdkman.sh"
}

if [[ -e "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    # shellcheck disable=SC1090
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

