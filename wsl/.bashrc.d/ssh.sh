# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if ! type gpgconf >/dev/null 2>&1; then
    return
fi

export SSH_AUTH_SOCK
SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

if [[ ! -z "${TERM_PROGRAM}" ]]; then
    return
fi

if [[ -d "${HOST_USER_HOME}/.ssh" ]]; then
    for f in $(grep -l 'PRIVATE KEY' ${HOST_USER_HOME}/.ssh/*); do
        mkdir -m 700 -p ${HOME}/.ssh
        cp ${f} ${HOME}/.ssh/
        chmod 600 ${HOME}/.ssh/$(basename ${f})
    done
    if [[ -e ${HOST_USER_HOME}/.ssh/config ]]; then
        cat ${HOST_USER_HOME}/.ssh/config > ${HOME}/.ssh/config
    fi
fi

grep -l 'PRIVATE KEY' ${HOME}/.ssh/* | xargs -r -L1 ssh-add

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
