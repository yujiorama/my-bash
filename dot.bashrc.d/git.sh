# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if ! which git-credential-manager >/dev/null 2>&1; then
    if [[ -d "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows" ]]; then
        PATH=${PATH}:"$(cygpath --unix "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows")"
    fi
fi

unset GIT_LFS_PATH

export GIT_SSH
if which plink >/dev/null 2>&1; then
    GIT_SSH=plink
elif which ssh >/dev/null 2>&1; then
    GIT_SSH=ssh
else
    :
fi

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto
export GIT_PS1_DESCRIBE_STYLE=branch
export GIT_PS1_SHOWCOLORHINTS=true

if [[ -e ${HOME}/git-prompt.sh ]]; then
    source ${HOME}/git-prompt.sh
elif [[ -e /mingw64/share/git/completion/git-prompt.sh ]]; then
    source /mingw64/share/git/completion/git-prompt.sh
fi
