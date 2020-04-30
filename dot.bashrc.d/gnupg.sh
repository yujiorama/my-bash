#!/bin/bash
# skip: no

if ! command -v gpg-agent >/dev/null 2>&1; then
    return
fi

if ! command -v gpg-connect-agent >/dev/null 2>&1; then
    return
fi

if ! command -v gpgconf >/dev/null 2>&1; then
    return
fi

if command -v scoop >/dev/null 2>&1; then
    confctl="$(cygpath -ma "$(scoop prefix gnupg)")/bin/gpgconf.ctl"
    ## XXX 空の設定ファイルがあると環境変数で動作を制御できなくなるので名前を変えておく
    if [[ -e "${confctl}" ]]; then
        [[ ! -s "${confctl}" ]] && mv "${confctl}" "${confctl}.bak"
    fi
    unset confctl
fi

export GPG_TTY
GPG_TTY=$(tty)

mkdir -p "${GNUPGHOME}"

if [[ "${OS}" = "Linux" ]]; then
    pinentry_program="$(command -v pinentry-curses)"
    ssh_support="enable-ssh-support"
else
    pinentry_program="$(cygpath -ma "$(command -v pinentry-basic.exe)")"
    ssh_support="enable-putty-support"
fi
cat - <<EOS > "${GNUPGHOME}/gpg-agent.conf"
pinentry-program ${pinentry_program}
${ssh_support}
log-file ${HOME}/gpg-agent.log
debug-level advanced
default-cache-ttl     86400
max-cache-ttl         86400
default-cache-ttl-ssh 86400
max-cache-ttl-ssh     86400
EOS
unset ssh_support

if ! gpg-agent 2>/dev/null; then
    if [[ "${OS}" = "Linux" ]]; then
        if [[ -d "${HOST_USER_HOME}/$(basename "${GNUPGHOME}")" ]]; then
            rsync --delete -avz \
                --exclude='gpg-agent.conf' \
                --exclude='sshcontrol' \
                --exclude='S.*' \
                --exclude='*.lock' \
                --exclude='private-keys-v1.d/*' \
                "${HOST_USER_HOME}/$(basename "${GNUPGHOME}")/" "${GNUPGHOME}/"
            find "${GNUPGHOME}" -type f -exec chmod 600 {} \;
        fi
    fi

    MSYS_NO_PATHCONV=1 gpg-connect-agent --homedir "${GNUPGHOME}" killagent '/bye'
    rm -f "${GNUPGHOME}"/S.*
    MSYS_NO_PATHCONV=1 gpg-connect-agent --homedir "${GNUPGHOME}" '/bye'
fi

if [[ "${OS}" = "Linux" ]]; then
    LANG=C MSYS_NO_PATHCONV=1 gpg-connect-agent --homedir "${GNUPGHOME}" updatestartuptty '/bye'
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        export SSH_AUTH_SOCK
        SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi
fi

cat - <<'EOS' >> "${HOME}/.bash_logout"

MSYS_NO_PATHCONV=1 gpg-connect-agent --homedir "${GNUPGHOME}" killagent '/bye'

if command -v taskkill >/dev/null 2>&1; then
    MSYS_NO_PATHCONV=1 taskkill /F /IM gpg-agent.exe
fi

if command -v pkill >/dev/null 2>&1; then
    pkill -KILL gpg-agent
    pkill -KILL gpg-agent
    pkill -KILL gpg-agent
fi

EOS
