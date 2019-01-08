if [[ -e ${HOME}/.ssh-agent.env ]]; then
    source ${HOME}/.ssh-agent.env
else
    SSH_AGENT_PID="none"
fi

agent_pid=$(ps aux | grep ssh-agent | grep -v grep | awk '{print $1}')
if [[ "${agent_pid}" != "${SSH_AGENT_PID}" ]]; then
    unset SSH_AUTH_SOCK SSH_AGENT_PID
    if [[ "${agent_pid}" != "" ]]; then
        if which pkill >/dev/null 2>&1; then
            pkill ssh-agent
        elif which taskkill >/dev/null 2>&1; then
            taskkill //F //IM ssh-agent.exe
        fi
    fi
    source <(ssh-agent -s | tee ${HOME}/.ssh-agent.env)
    for f in $(grep -l 'PRIVATE KEY' ${HOME}/.ssh/*); do
        ssh-add -q ${f}
    done
fi
