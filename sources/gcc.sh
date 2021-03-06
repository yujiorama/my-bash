# shellcheck shell=bash

PATH=$(echo "$PATH" | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'gcc' | tr '\n' ':')

if [[ -d "${HOME}/scoop/apps/gcc/current" ]]; then
    export PATH
    PATH=${PATH}:${HOME}/scoop/apps/gcc/current/bin
fi
