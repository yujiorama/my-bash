# shellcheck shell=bash

if ! command -v starship >/dev/null 2>&1; then
    return
fi

starship init bash > "${MY_BASH_ENV}/starship"
ls -l "${MY_BASH_ENV}/starship"
