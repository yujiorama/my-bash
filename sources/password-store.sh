# shellcheck shell=bash

if ! command -v pass >/dev/null 2>&1; then
    return
fi

if [[ -e "${HOME}/bin/password-store/share/bash-completion/completions/pass" ]]; then
    cp "${HOME}/bin/password-store/share/bash-completion/completions/pass" "${MY_BASH_COMPLETION}/pass"
fi

if [[ -e "/usr/share/bash-completion/completions/pass" ]]; then
    cp "/usr/share/bash-completion/completions/pass" "${MY_BASH_COMPLETION}/pass"
fi

if [[ "${OS}" = "Linux" ]]; then
    if [[ ! -d "${HOST_USER_HOME}/.password-store" ]]; then
        return
    fi

    if ! command -v rsync >/dev/null 2>&1; then
        return
    fi

    passstore_dir="${HOME}/.password-store"
    mkdir -p "${passstore_dir}"
    rsync --delete -az "${HOST_USER_HOME}/.password-store/" "${passstore_dir}/"
    chmod 700 "${passstore_dir}"
    /usr/bin/find -L "${passstore_dir}" -type d | xargs -r chmod 700
    /usr/bin/find -L "${passstore_dir}" -type f | xargs -r chmod 600
    unset passstore_dir
fi
