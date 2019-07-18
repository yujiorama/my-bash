# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -n "${TERM_PROGRAM}" ]]; then
    return
fi

if [[ -d "${HOST_USER_HOME}/.ssh" ]]; then
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    grep -l 'PRIVATE KEY' "${HOST_USER_HOME}/.ssh/"* | while read -r f; do
        cp "${f}" "${HOME}/.ssh/"
        if [[ -e "${f}.pub" ]]; then
            cp "${f}.pub" "${HOME}/.ssh/"
            chmod 600 "${HOME}/.ssh/$(basename "${f}").pub"
        fi
        chmod 600 "${HOME}/.ssh/$(basename "${f}")"
    done
    if [[ -e "${HOST_USER_HOME}/.ssh/config" ]]; then
        cat "${HOST_USER_HOME}/.ssh/config" > "${HOME}/.ssh/config"
        chmod 600 "${HOME}/.ssh/config"
    fi
fi

if ! pgrep ssh-agent >/dev/null 2>&1; then
    ssh-agent -s > "${HOME}/.ssh_environment"
fi

if [[ -e "${HOME}/.ssh_environment" ]]; then
    source "${HOME}/.ssh_environment"
    grep -l 'PRIVATE KEY' "${HOME}/.ssh/"* | while read -r f; do
        if [[ -e "${f}.pub" ]]; then
            if grep -f "${f}.pub" <(ssh-add -L) >/dev/null 2>&1; then
                continue
            fi
        fi
        ssh-add -t 86400 "${f}"
    done
fi

__hostname_completion()
{
    local ssh_config_ compword_ hosts_
    if [[ -e "${HOME}/.ssh/config" ]]; then
        ssh_config_="${HOME}/.ssh/config"
    elif [[ -e "/etc/ssh/ssh_config" ]]; then
        ssh_config_="/etc/ssh/ssh_config"
    else
        return
    fi
    compword_="${COMP_WORDS[${COMP_CWORD}]}"
    hosts_=$(grep -E '^Host' ${ssh_config_} | cut -c6- | grep -v '*' | sort -d | tr '\n' ' ')
    COMPREPLY=($(compgen -W "${hosts_}" -- "${compword_}"))
}

complete -o default -o nospace -F __hostname_completion ssh
