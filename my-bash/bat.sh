#!/bin/bash
# skip: no


function bat-install {

    if [[ "${OS}" == "Linux" ]]; then
        local latest jqfilter
        latest="https://api.github.com/repos/sharkdp/bat/releases/latest"
        jqfilter='.assets[] | select(.name | startswith("bat_")) | select(.name | endswith("_amd64.deb")) | .browser_download_url'

        local url
        url="$(curl -fsSL "${latest}" | jq -r "${jqfilter}")"
        if [[ -z "${url}" ]]; then
            return
        fi

        local deb
        deb="$(mktemp).deb"

        curl -fsSL --output "${deb}" "${url}"

        sudo apt install -qq -y "${deb}"

        rm -f "${deb}"
    fi

    if [[ "${OS}" != "Linux" ]]; then

        if ! command -v scoop >/dev/null 2>&1; then
            return
        fi

        if ! command -v bat >/dev/null 2>&1; then
            scoop install bat
        else
            scoop update bat
        fi
    fi

    bat --version
}

export BAT_CONFIG_PATH
BAT_CONFIG_PATH="${HOME}/.bat"

if [[ ! -e "${BAT_CONFIG_PATH}" ]]; then
    cat - <<EOS > "${BAT_CONFIG_PATH}"
--theme="ansi-dark"
--italic-text=always
--paging=auto
#--pager="--RAW-CONTROL-CHARS --quit-if-one-screen"
EOS
fi
