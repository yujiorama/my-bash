unset GIT_LFS_PATH

if [[ -d "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows" ]]; then
    cygpath --unix "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows" >> ${HOME}/.bash_path_suffix
fi

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
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_DESCRIBE_STYLE="branch"
export GIT_PS1_SHOWCOLORHINTS=true

here()
{
	cygpath -wa "$PWD"
}
export PS1
# PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ '
PS1='\033[35m\]\u@\h `here`\n\[\033[33m\]\w\[\033[36m\]`__git_ps1 " (%s)"`\[\033[0m\]\n$ '
source ${HOME}/git-prompt.sh
