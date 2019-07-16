# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -n "${TERM_PROGRAM}" ]]; then
    return
fi

if ! type pass >/dev/null 2>&1; then
    return
fi

if [[ ! -d ${HOST_USER_HOME}/.password-store ]]; then
    return
fi

# shellcheck source=/dev/null
[[ -e "/usr/share/bash-completion/completions/pass" ]] && source "/usr/share/bash-completion/completions/pass"

passstore_dir="${HOME}/.password-store/"
if [[ -d "${HOST_USER_HOME}/.password-store/" ]]; then
    rsync --delete -az "${HOST_USER_HOME}/.password-store/" "${passstore_dir}"
    chmod 700 "${passstore_dir}"
    /usr/bin/find "${passstore_dir}" -type d | xargs -r chmod 700
    /usr/bin/find "${passstore_dir}" -type f | xargs -r chmod 600
fi
