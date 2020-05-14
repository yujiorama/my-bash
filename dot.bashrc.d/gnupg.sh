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

if ! command -v gpg >/dev/null 2>&1; then
    return
fi

function gpg-new-key {
    local key_home
    key_home="${HOME}/gpg"
    mkdir -p "${key_home}"
    local name email
    name="${1}"; shift
    email="${1}"; shift
    if [[ -z "${name}" ]] || [[ -z "${email}" ]]; then
        return
    fi
    local conf
    conf="${key_home}/${email}.conf"
    if [[ -e "${conf}" ]]; then
        return
    fi
    local keytype keylength
    keytype="${1:-RSA}"; shift
    keylength="${1:-4096}"; shift
    local expire
    expire="${1:-10y}"; shift

    local passphrase
    read -r -s -p 'passphrase?: ' passphrase

    cat - <<EOS > "${conf}"
# Unattended GPG key generation - Using the GNU Privacy Guard
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
%echo Generating a basic OpenPGP key
Key-Type: ${keytype}
Key-Length: ${keylength}

Subkey-Type: ${keytype}
Subkey-Length: ${keylength}

Expire-Date: ${expire}

Name-Real: ${name}
Name-Email: ${email}

Passphrase: ${passphrase}

%commit
%echo Successfully done
EOS

    gpg --batch --generate-key "${conf}"
    gpg --list-secret-keys --keyid-format long
}

function gpg-export-secret {
    local key
    key="${1}"
    if [[ ! -e "${key}" ]]; then
        return
    fi
    local secret_key
    secret_key="${1:-${key}.secret}"; shift
    if [[ -e "${secret_key}" ]]; then
        return
    fi
    local keyid
    keyid=$(LANG=C gpg --show-keys --keyid-format long "${key}" \
    | awk '{if($1=="pub"){print substr($2,1+match($2,"/"))}}') # $2="algo/keyid" -> "keyid"

    gpg --armor --export-secret-key "${keyid}" > "${secret_key}"
}

function gpg-revoke-key {
    local key
    key="${1}"; shift
    if [[ ! -e "${key}" ]]; then
        return
    fi
    local revoke_key
    revoke_key="${1:-${key}.revoke}"; shift
    if [[ -e "${revoke_key}" ]]; then
        return
    fi
    local keyid
    keyid=$(LANG=C gpg --show-keys --keyid-format long "${key}" \
    | awk '{if($1=="pub"){print substr($2,1+match($2,"/"))}}') # $2="algo/keyid" -> "keyid"

    gpg --gen-revoke "${keyid}" --output "${revoke_key}"
}

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
chmod 700 "${GNUPGHOME}"

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
unset pinentry_program ssh_support

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
            chmod 700 "${GNUPGHOME}"
        fi
    fi

    MSYS_NO_PATHCONV=1 gpg-connect-agent --homedir "${GNUPGHOME}" killagent '/bye'
    rm -f "${GNUPGHOME}"/S.*
    MSYS_NO_PATHCONV=1 gpg-connect-agent --homedir "${GNUPGHOME}" '/bye'
    MSYS_NO_PATHCONV=1 gpg-connect-agent --homedir "${GNUPGHOME}" updatestartuptty '/bye'
fi

if [[ "${OS}" != "Linux" ]]; then
    if [[ -d "${HOME}/gpg" ]]; then
        find "${HOME}/gpg" -type f -name \*.gpg | while read -r f; do
            gpg-export-secret "${f}" "${f}.key"
            gpg-revoke-key "${f}" "${f}.revoke"
        done
        gpg --list-secret-keys --keyid-format long
    fi
fi

if [[ "${OS}" = "Linux" ]]; then
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        export SSH_AUTH_SOCK
        SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi

    if [[ -d "${HOST_USER_HOME}/gpg" ]]; then
        rsync --delete -avz "${HOST_USER_HOME}/gpg/" "${HOME}/gpg/"
        find "${HOME}/gpg" -type f -exec grep --text -l "PRIVATE" {} \; | while read -r f; do
            gpg --import "${f}"
        done
        gpg --list-secret-keys --keyid-format long
    fi
fi

cat - <<'EOS' > "${MY_BASH_LOGOUT}/gnupg"

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
