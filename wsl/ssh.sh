#!/bin/bash

if [[ -d "${HOST_USER_HOME}/.ssh" ]]; then
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    grep -l 'PRIVATE KEY' "${HOST_USER_HOME}/.ssh/"* | while read -r f; do
        cat "${f}" > "${HOME}/.ssh/$(basename "${f}")"
        chmod 600 "${HOME}/.ssh/$(basename "${f}")"
        if [[ -e "${f}.pub" ]]; then
            cat "${f}.pub" > "${HOME}/.ssh/$(basename "${f}.pub")"
            chmod 600 "${HOME}/.ssh/$(basename "${f}").pub"
        fi
    done
    if [[ -e "${HOST_USER_HOME}/.ssh/config" ]]; then
        cat "${HOST_USER_HOME}/.ssh/config" > "${HOME}/.ssh/config"
        chmod 600 "${HOME}/.ssh/config"
    fi
fi

# if ! pgrep ssh-agent >/dev/null 2>&1; then
#     ssh-agent -s > "${HOME}/.env.ssh"
# fi

# if [[ -e "${HOME}/.env.ssh" ]]; then
#     # shellcheck disable=SC1090
#     source "${HOME}/.env.ssh"
#     grep -l 'PRIVATE KEY' "${HOME}/.ssh/"* | while read -r f; do
#         if [[ -e "${f}.pub" ]]; then
#             if grep -f "${f}.pub" <(ssh-add -L) >/dev/null 2>&1; then
#                 continue
#             fi
#         fi
#         ssh-add -t 86400 "${f}"
#     done
# fi
