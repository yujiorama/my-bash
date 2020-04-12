#!/bin/bash
PATH=$(echo "$PATH" | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'sdkman' | tr '\n' ':')

export SDKMAN_DIR
SDKMAN_DIR="${HOME}/.sdkman"
if [[ -e "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    # shellcheck disable=SC1090
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

function sdkman-install {
    if [[ "${OS}" = "Linux" ]]; then
        sudo apt install -y curl zip unzip
    fi

    if online "get.sdkman.io" 443; then
        curl -fsSL "https://get.sdkman.io" | bash
    fi

    if [[ -e "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
        # shellcheck disable=SC1090
        source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    fi
}
