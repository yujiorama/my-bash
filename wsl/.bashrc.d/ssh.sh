# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

HOST_USER_HOME=/mnt/c/Users/y_okazawa
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

if [[ -e ${HOME}/.ssh-agent.env ]]; then
    source ${HOME}/.ssh-agent.env
else
    SSH_AGENT_PID="none"
fi

if which ssh-agent >/dev/null 2>&1; then
    agent_pid=$(ps -ef | grep ssh-agent | grep -v grep | awk '{print $2}')
    if [[ "${agent_pid}" != "${SSH_AGENT_PID}" ]]; then
        unset SSH_AUTH_SOCK SSH_AGENT_PID
        if [[ "${agent_pid}" != "" ]]; then
            if which pkill 2>&1 >/dev/null; then
                pkill ssh-agent
            elif which taskkill 2>&1 >/dev/null; then
                taskkill //F //IM ssh-agent.exe
            fi
        fi
        source <(ssh-agent -s | tee ${HOME}/.ssh-agent.env)
        for f in $(grep -l 'PRIVATE KEY' ${HOME}/.ssh/*); do
            ssh-add ${f}
        done
    fi
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
