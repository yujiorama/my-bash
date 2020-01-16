# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if another_console_exists; then
    return
fi

# https://github.com/tfutils/tfenv

if command -v git >/dev/null 2>&1; then
    if [[ ! -d ${HOME}/.tfenv ]]; then
        git clone https://github.com/tfutils/tfenv.git "${HOME}/.tfenv"
    else
        (cd "${HOME}/.tfenv" && git pull)
    fi
fi
