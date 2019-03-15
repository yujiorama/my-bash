if ! which git-credential-manager 2>&1 >/dev/null; then
    if [[ -d "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows" ]]; then
        PATH=${PATH}:"$(cygpath --unix "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows")"
    fi
fi

unset GIT_LFS_PATH

export GIT_SSH
if which plink 2>&1 >/dev/null; then
    GIT_SSH=plink
elif which ssh 2>&1 >/dev/null; then
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

export PS1
# PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ '
PS1='\033[35m\]\u@\h `here`\n\[\033[33m\]\w\[\033[36m\]`__git_ps1 " (%s)"`\[\033[0m\]\n$ '
if [[ -e ${HOME}/git-prompt.sh ]]; then
    source ${HOME}/git-prompt.sh
elif [[ -e source /mingw64/share/git/completion/git-prompt.sh ]]; then
    source /mingw64/share/git/completion/git-prompt.sh
fi
