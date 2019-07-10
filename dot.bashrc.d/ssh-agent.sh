# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

GNUPG_BIN="${HOME}/scoop/apps/gnupg/current/bin"

if [[ ! -d "${GNUPG_BIN}" ]]; then
    return
fi

export GNUPGHOME
GNUPGHOME="${HOME}/.gnupg"

/bin/cat - > ${GNUPGHOME}/gpg-agent.conf << EOS
log-file gpg-agent.log
enable-putty-support
default-cache-ttl     3600
max-cache-ttl         36000
default-cache-ttl-ssh 3600
max-cache-ttl-ssh     36000
EOS
${GNUPG_BIN}/gpg-connect-agent killagent '//bye'
${GNUPG_BIN}/gpg-connect-agent '//bye'

source <(/usr/bin/ssh-pageant -s --reuse -a "${HOME}/.ssh-pageant-${USERNAME}")
for ppk in $(/bin/find ${HOME}/.ssh -type f -name \*.ppk); do
  echo "${ppk}"
  pageant ${ppk}
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
#         if which pkill >/dev/null 2>&1; then
#             pkill ssh-pageant
#         elif which taskkill >/dev/null 2>&1; then
#             taskkill //F //IM ssh-pageant.exe
#         fi
#     fi
#     source <(ssh-pageant -s | tee ${HOME}/.ssh-agent.env)
#     grep -l 'PRIVATE KEY' ${HOME}/.ssh/* | xargs -L1 -I{} ssh-add -q {}
# fi

# C:\Users\y_okazawa\scoop\apps\putty\current\PAGEANT.EXE C:\Users\y_okazawa\.ssh\id_ed25519.ppk
