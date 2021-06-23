# shellcheck shell=bash
# skip: no

cat - <<'EOS' > "${MY_BASH_COMPLETION}/ssh"
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

if [[ "${OS}" != "Linux" ]]; then

    if ! command -v ssh-pageant >/dev/null 2>&1; then
        return
    fi

    if ! command -v pageant >/dev/null 2>&1; then
        return
    fi

    # shellcheck source=/dev/null
    source <( ssh-pageant -s --reuse -a "${HOME}/.ssh-pageant-${USERNAME}" )
    if [[ -n "${SSH_AUTH_SOCK}" ]]; then
        export SSH_AUTH_SOCK
        SSH_AUTH_SOCK="$(cygpath -ma "${SSH_AUTH_SOCK}")"
    fi
    # shellcheck disable=SC2046
    pageant $(/usr/bin/find -L "${HOME}/.ssh" -type f -name \*.ppk | xargs -r -I{} cygpath -ma {})

else

    if [[ -d "${HOST_USER_HOME}/.ssh" ]]; then
        mkdir -p "${HOME}/.ssh"
        find "${HOST_USER_HOME}/.ssh" -maxdepth 1 -type f -a -not -name \*.ppk | while read -r f; do
            cat "${f}" > "${HOME}/.ssh/$(basename "${f}")"
        done
        chmod 700 "${HOME}/.ssh"
        find "${HOME}/.ssh" -type f -exec chmod 600 {} \;
    fi

    if gpg-agent 2>/dev/null; then
        gpg-connect-agent --homedir "${GNUPGHOME}" updatestartuptty '/bye'
        unset SSH_AUTH_SOCK SSH_AGENT_PID
        export SSH_AUTH_SOCK
        SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi

    /usr/bin/find "${HOME}/.ssh" -type f \
    | xargs -r grep -l 'PRIVATE KEY' \
    | while read -r f; do
        fp="$(ssh-keygen -lf "${f}" | cut -d ' ' -f 1,2)"
        if ! grep "${fp}" <(ssh-add -l) >/dev/null 2>&1; then
            ssh-add -q "${f}"
        fi
        unset fp
    done
fi


# if [[ -e ${HOME}/.ssh-agent.env ]]; then
#     # shellcheck disable=SC1090
#     source "${HOME}/.ssh-agent.env"
# else
#     SSH_AGENT_PID="none"
# fi
#
# if [[ "${OS}" != "Linux" ]]; then
#   agent_pid=$(ps -ef | grep ssh-pageant | grep -v grep | awk '{print $2}')
#   if [[ "${agent_pid}" != "${SSH_AGENT_PID}" ]]; then
#       unset SSH_AUTH_SOCK SSH_AGENT_PID
#       if [[ -n "${agent_pid}" ]]; then
#           if command -v pkill >/dev/null 2>&1; then
#               pkill ssh-pageant
#           elif command -v taskkill >/dev/null 2>&1; then
#               MSYS_NO_PATHCONV=1 taskkill /F /IM ssh-pageant.exe
#           fi
#       fi
#       source <(ssh-pageant -s | tee ${HOME}/.ssh-agent.env)
#       grep -l 'PRIVATE KEY' ${HOME}/.ssh/* | xargs -L1 -I{} ssh-add -q {}
#   fi
#   unset agent_pid
# else
#   agent_pid=$(pgrep ssh-agent)
#   if [[ "${agent_pid}" != "${SSH_AGENT_PID}" ]]; then
#       unset SSH_AUTH_SOCK SSH_AGENT_PID
#       if [[ -n "${agent_pid}" ]]; then
#           if command -v pkill >/dev/null 2>&1; then
#               pkill ssh-pageant
#           elif command -v taskkill >/dev/null 2>&1; then
#               MSYS_NO_PATHCONV=1 taskkill /F /IM ssh-pageant.exe
#           fi
#       fi
#       source <(ssh-ageant -s | tee ${HOME}/.ssh-agent.env)
#       grep -l 'PRIVATE KEY' ${HOME}/.ssh/* | xargs -L1 -I{} ssh-add -q {}
#   fi
#   unset agent_pid
# fi

cat - <<'EOS' > "${MY_BASH_LOGOUT}/ssh"

if command -v ssh-pagent >/dev/null 2>&1; then
    ssh-pageant -k
fi

if command -v taskkill >/dev/null 2>&1; then
    MSYS_NO_PATHCONV=1 taskkill /F /IM ssh-pageant.exe
fi

EOS
