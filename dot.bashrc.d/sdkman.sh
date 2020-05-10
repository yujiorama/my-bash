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

if ! command -v sdk >/dev/null 2>&1; then
    return
fi

cat - <<EOS > "${SDKMAN_DIR}/etc/config"
sdkman_auto_answer=true
sdkman_auto_selfupdate=true
sdkman_insecure_ssl=false
sdkman_curl_connect_timeout=7
sdkman_curl_max_time=10
sdkman_beta_channel=false
sdkman_debug_mode=false
sdkman_colour_enable=true
sdkman_auto_env=false
EOS

for v in maven gradle; do
    sdk install "${v}"
    sdk current "${v}"
done
