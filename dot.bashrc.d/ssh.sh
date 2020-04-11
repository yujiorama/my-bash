#!/bin/bash
# skip: no

if ! command -v ssh-pageant >/dev/null 2>&1; then
    return
fi

if ! command -v pageant >/dev/null 2>&1; then
    return
fi


cat - <<'EOS' > "${HOME}/.completion/ssh"
function __hostname_completion {
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
EOS

# shellcheck source=/dev/null
source <( ssh-pageant -s --reuse -a "${HOME}/.ssh-pageant-${USERNAME}" )
if [[ -n "${SSH_AUTH_SOCK}" ]]; then
    export SSH_AUTH_SOCK
    SSH_AUTH_SOCK="$(cygpath -ma "${SSH_AUTH_SOCK}")"
fi
# shellcheck disable=SC2046
pageant $(/usr/bin/find -L "${HOME}/.ssh" -type f -name \*.ppk | xargs -r -L1 -I{} cygpath -ma {})

# if [[ -e ${HOME}/.ssh-agent.env ]]; then
#     source <(/bin/cat ${HOME}/.ssh-agent.env)
# else
#     SSH_AGENT_PID="none"
# fi

# agent_pid=$(ps -ef | grep ssh-pageant | grep -v grep | awk '{print $2}')
# if [[ "${agent_pid}" != "${SSH_AGENT_PID}" ]]; then
#     unset SSH_AUTH_SOCK SSH_AGENT_PID
#     if [[ "${agent_pid}" != "" ]]; then
#         if command -v pkill >/dev/null 2>&1; then
#             pkill ssh-pageant
#         elif command -v taskkill >/dev/null 2>&1; then
#             taskkill //F //IM ssh-pageant.exe
#         fi
#     fi
#     source <(ssh-pageant -s | tee ${HOME}/.ssh-agent.env)
#     grep -l 'PRIVATE KEY' ${HOME}/.ssh/* | xargs -L1 -I{} ssh-add -q {}
# fi
