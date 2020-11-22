# shellcheck shell=bash

PATH=$(echo "$PATH" | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'nodejs' | tr '\n' ':')

if [[ -d "${HOME}/scoop/apps/nodejs-lts/current" ]]; then
    export PATH
    PATH=${PATH}:${HOME}/scoop/apps/nodejs-lts/current/bin
    PATH=${PATH}:${HOME}/scoop/apps/nodejs-lts/current
fi

if [[ -d "${HOME}/.nodejs/bin" ]]; then
    PATH=${HOME}/.nodejs/bin:${PATH}
fi
