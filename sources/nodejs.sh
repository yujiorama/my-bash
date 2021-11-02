# shellcheck shell=bash

PATH=$(echo "$PATH" | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'nodejs' | tr '\n' ':')

if [[ -d "${HOME}/scoop/apps/nodejs-lts/current" ]]; then
    export PATH
    PATH=${PATH}:${HOME}/scoop/apps/nodejs-lts/current/bin
    PATH=${PATH}:${HOME}/scoop/apps/nodejs-lts/current
fi

mkdir -p "${HOME}/.nodejs/node_modules"
export PATH
PATH=${HOME}/.nodejs:${PATH}
