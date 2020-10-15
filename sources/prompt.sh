# shellcheck shell=bash

if set | grep -E '^MSYS2_PS1=' >/dev/null 2>&1; then
    export MSYS2_PS1="${MSYS2_PS1}"
    function prompt-msys2 {
        PS1=${MSYS2_PS1}
    }
fi

if declare -f __git_ps1 >/dev/null 2>&1; then
    export SIMPLE_PS1
    if [[ "${OS}" = "Linux" ]]; then
        # shellcheck disable=SC2016
        SIMPLE_PS1='\[\033[1;36m\]`uname -r -s` \[\033[1;33m\]\u@\h \[\033[1;34m\]\w \[\033[1;35m\]`__git_ps1` \[\033[0m\]\n$ '
    else
        # shellcheck disable=SC2016
        SIMPLE_PS1='\[\033[1;32m\]$MSYSTEM \[\033[1;33m\]\u@\h \[\033[1;34m\]\w \[\033[1;35m\]`__git_ps1` \[\033[0m\]\n$ '
    fi

    function prompt-simple {
        PS1=$SIMPLE_PS1
    }
fi

if [[ -z "${PS1}" ]]; then
    PS1='\[\e[35m\]\u@\h\[\e[0m\]\n$ '
fi

export DEFAULT_PS1="${PS1}"
function prompt-default {
    PS1=${DEFAULT_PS1}
}

prompt-simple
