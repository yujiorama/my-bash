# shellcheck shell=bash

PATH=$(echo "$PATH" | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'nodejs' | tr '\n' ':')

if [[ -d "${HOME}/scoop/apps/nodejs-lts/current" ]]; then
    export PATH
    PATH=${PATH}:${HOME}/scoop/apps/nodejs-lts/current/bin
    PATH=${PATH}:${HOME}/scoop/apps/nodejs-lts/current
fi

if command -v npm >/dev/null 2>&1; then
    mkdir -p "${HOME}/.nodejs"
    npm set prefix "${HOME}/.nodejs"
    PATH=${HOME}/.nodejs:${PATH}
fi
