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

## XXX 空の設定ファイルがあると環境変数で動作を制御できなくなるので名前を変えておく
confctl="$(cygpath -ma "$(scoop prefix gnupg)")/bin/gpgconf.ctl"
if [[ -e "${confctl}" ]]; then
    [[ ! -s "${confctl}" ]] && mv "${confctl}" "${confctl}.bak"
fi
unset confctl

if ! gpg-agent 2>/dev/null; then
    mkdir -p "${GNUPGHOME}"

    cat - <<EOS > "${GNUPGHOME}/gpg-agent.conf"
log-file gpg-agent.log
enable-putty-support
default-cache-ttl     86400
max-cache-ttl         86400
default-cache-ttl-ssh 86400
max-cache-ttl-ssh     86400
EOS

    gpg-connect-agent --homedir "${GNUPGHOME}" killagent '//bye'
    rm -f "${GNUPGHOME}"/S.*
    gpg-connect-agent --homedir "${GNUPGHOME}" '//bye'
fi
