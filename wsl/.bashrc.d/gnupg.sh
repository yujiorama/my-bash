# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -n "${WSLENV}" ]]; then
    return
fi

if ! type gpg-agent >/dev/null 2>&1; then
    return
fi

if ! type gpg-connect-agent >/dev/null 2>&1; then
    return
fi

if [[ ! -d ${HOST_USER_HOME}/.gnupg ]]; then
    return
fi

if ! gpg-agent 2>/dev/null; then
    mkdir -p "${GNUPGHOME}"
    if [[ -d "${HOST_USER_HOME}/.gnupg/" ]]; then
        /usr/bin/rsync --delete -az "${HOST_USER_HOME}/.gnupg/" "${GNUPGHOME}"
        /bin/rm -f "${GNUPGHOME}/gnupg_spawn_agent_sentinel.lock" "${GNUPGHOME}"/S.* "${GNUPGHOME}/sshcontrol"
    fi

    /bin/cat - > "${GNUPGHOME}/gpg-agent.conf" << EOS
    log-file gpg-agent.log
    default-cache-ttl     86400
    max-cache-ttl         86400
EOS
    /bin/chmod 700 "${GNUPGHOME}"
    /usr/bin/find -L "${GNUPGHOME}" -type d | xargs -r chmod 700
    /usr/bin/find -L "${GNUPGHOME}" -type f | xargs -r chmod 600

    gpg-connect-agent --homedir "${GNUPGHOME}" killagent '/bye'
    gpg-connect-agent --homedir "${GNUPGHOME}" '/bye'
fi
