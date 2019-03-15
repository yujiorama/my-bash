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

__here()
{
    case ${OS:-Linux} in
        Windows*) cygpath -wa "${PWD}" ;;
        *)        echo ${PWD} ;;
    esac
}
alias here='__here'

export PS1
# PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ '
PS1='\033[01;32m\]\u@\h `here`\n\[\033[33m\]\w\[\033[36m\]`__git_ps1 " (%s)"`\[\033[0m\]\n$ '
if [[ -e ${HOME}/git-prompt.sh ]]; then
    source ${HOME}/git-prompt.sh
elif [[ -e /mingw64/share/git/completion/git-prompt.sh ]]; then
    source /mingw64/share/git/completion/git-prompt.sh
elif [[ -e /etc/bash_completion.d ]] && [[ -e /etc/bash_completion.d/git-prompt ]]; then
    source /etc/bash_completion.d/git-prompt
fi
