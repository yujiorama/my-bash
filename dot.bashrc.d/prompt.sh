#!/bin/bash

if set | grep -E '^MSYS2_PS1=' >/dev/null 2>&1; then
    export MSYS2_PS1="${MSYS2_PS1}"
    function prompt-msys2 {
        PS1=${MSYS2_PS1}
    }
fi

if declare -f __here >/dev/null 2>&1; then
    export SIMPLE_PS1
    # shellcheck disable=SC2016
    SIMPLE_PS1='\[\e[35m\]\u@\h `__here`\[\e[0m\]\n$ '

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

prompt-default
