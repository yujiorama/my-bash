#!/bin/bash

mkdir -p "${DIR_COLORS}"

function dircolors-ansi-dark {
    local url colors_file
    url="https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-dark"
    colors_file="$(basename "${url}")"
    if online raw.githubusercontent.com 443; then
        download_new_file "${url}" "${DIR_COLORS}/${colors_file}"
    fi
    if [[ -e "${DIR_COLORS}/${colors_file}" ]]; then
        # shellcheck disable=SC1090
        source <(dircolors "${DIR_COLORS}/${colors_file}")
    fi
}

function dircolors-ansi-light {
    local url
    url="https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-light"
    colors_file="$(basename "${url}")"
    if online raw.githubusercontent.com 443; then
        download_new_file "${url}" "${DIR_COLORS}/${colors_file}"
    fi
    if [[ -e "${DIR_COLORS}/${colors_file}" ]]; then
        # shellcheck disable=SC1090
        source <(dircolors "${DIR_COLORS}/${colors_file}")
    fi
}

function dircolors-ansi-universal {
    local url
    url="https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-universal"
    colors_file="$(basename "${url}")"
    if online raw.githubusercontent.com 443; then
        download_new_file "${url}" "${DIR_COLORS}/${colors_file}"
    fi
    if [[ -e "${DIR_COLORS}/${colors_file}" ]]; then
        # shellcheck disable=SC1090
        source <(dircolors "${DIR_COLORS}/${colors_file}")
    fi
}

function dircolors-default {
    # shellcheck disable=SC1090
    source <(dircolors --sh)
}

dircolors-default
