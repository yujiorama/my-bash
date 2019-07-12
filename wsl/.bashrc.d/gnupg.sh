# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -n "${TERM_PROGRAM}" ]]; then
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
    gnupg_dir="${HOME}/.gnupg/"
    /usr/bin/rsync --delete -az "${HOST_USER_HOME}/.gnupg/" "${gnupg_dir}"
    /bin/rm -f "${gnupg_dir}/gnupg_spawn_agent_sentinel.lock" "${gnupg_dir}"/S.* "${gnupg_dir}/sshcontrol"

    /bin/chmod 700 "${gnupg_dir}"
    /usr/bin/find "${gnupg_dir}" -type d | xargs -r chmod 700
    /usr/bin/find "${gnupg_dir}" -type f | xargs -r chmod 600

    gpg-connect-agent --homedir "${GNUPGHOME}" killagent '/bye'
    gpg-connect-agent --homedir "${GNUPGHOME}" '/bye'
fi
