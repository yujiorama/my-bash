# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if ! type pass >/dev/null 2>&1; then
    return
fi

if [[ ! -d /mnt/c/Users/y_okazawa/.password-store ]]; then
    return
fi

gnupg_dir="${HOME}/.gnupg/"
passstore_dir="${HOME}/.password-store/"
rsync --delete -az /mnt/c/Users/y_okazawa/.gnupg/ ${gnupg_dir}
rsync --delete -az /mnt/c/Users/y_okazawa/.password-store/ ${passstore_dir}

chmod 700 ${gnupg_dir} ${passstore_dir}
find ${gnupg_dir} ${passstore_dir} -type d | xargs -r chmod 700
find ${gnupg_dir} ${passstore_dir} -type f | xargs -r chmod 600
