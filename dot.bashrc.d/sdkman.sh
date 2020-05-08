#!/bin/bash
# skip: no

function sdkman-install {
    if [[ "${OS}" = "Linux" ]]; then
        sudo apt install -y curl zip unzip
    fi

    if online "get.sdkman.io" 443; then
        curl -fsSL "https://get.sdkman.io" | bash
    fi

    # shellcheck disable=SC1090
    [[ -e "${MY_BASH_SOURCES}/sdkman.env" ]] && source "${MY_BASH_SOURCES}/sdkman.env"
    # shellcheck disable=SC1090
    [[ -e "${MY_BASH_SOURCES}/sdkman.sh" ]] && source "${MY_BASH_SOURCES}/sdkman.sh"
}

if [[ -e "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    # shellcheck disable=SC1090
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi
