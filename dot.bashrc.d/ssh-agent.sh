# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -e ${HOME}/.ssh-agent.env ]]; then
    source <(/bin/cat ${HOME}/.ssh-agent.env)
else
    SSH_AGENT_PID="none"
fi

agent_pid=$(ps -ef | grep ssh-agent | grep -v grep | awk '{print $2}')
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
    grep -l 'PRIVATE KEY' ${HOME}/.ssh/* | xargs -L1 -I{} ssh-add -q {}
fi
