#!/bin/bash
if ! type ssh-pageant >/dev/null 2>&1; then
    return
fi

if ! type pageant >/dev/null 2>&1; then
    return
fi

# shellcheck source=/dev/null
source <( ssh-pageant -s --reuse -a "${HOME}/.ssh-pageant-${USERNAME}" )
/usr/bin/find -L "${HOME}/.ssh" -type f -name \*.ppk | while read -r ppk; do
  /bin/echo "${ppk}"
  pageant "${ppk}"
done

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
