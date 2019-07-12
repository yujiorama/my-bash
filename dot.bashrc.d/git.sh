# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -e ${HOME}/git-prompt.sh ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/git-prompt.sh"
fi
if [[ -e /mingw64/share/git/completion/git-prompt.sh ]]; then
    # shellcheck source=/dev/null
    source "/mingw64/share/git/completion/git-prompt.sh"
fi
