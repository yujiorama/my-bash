if [[ -d /usr/share/git/completion ]]; then
    for f in /usr/share/git/completion/*.bash /usr/share/git/completion/*.sh /mingw64/share/git/completion/*.bash; do
        source ${f}
    done
    GIT_PS1_SHOWDIRTYSTATE=
    GIT_PS1_SHOWUPSTREAM=1
    GIT_PS1_SHOWUNTRACKEDFILES=
    GIT_PS1_SHOWSTASHSTATE=1
    export PS1='\[\033]0;$TITLEPREFIX:${PWD//[^[:ascii:]]/?}\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ '
fi
