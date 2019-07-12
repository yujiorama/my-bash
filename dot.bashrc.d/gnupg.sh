# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if ! type gpg-agent >/dev/null 2>&1; then
    return
fi

if ! type gpg-connect-agent >/dev/null 2>&1; then
    return
fi

if ! gpg-agent 2>/dev/null; then
    mkdir -p "${GNUPGHOME}"

    /bin/cat - > "${GNUPGHOME}/gpg-agent.conf" << EOS
    log-file gpg-agent.log
    enable-putty-support
    default-cache-ttl     86400
    max-cache-ttl         86400
    default-cache-ttl-ssh 86400
    max-cache-ttl-ssh     86400
EOS

    gpg-connect-agent --homedir "${GNUPGHOME}" killagent '//bye'
    gpg-connect-agent --homedir "${GNUPGHOME}" '//bye'
fi
