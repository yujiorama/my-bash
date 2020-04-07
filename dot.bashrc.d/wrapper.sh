#!/bin/bash
function open {
    start "$(readlink -m "$1")"
}

function iview {
    local a=$1
    "$(cygpath -ma "$(scoop prefix irfanview)")/i_view64.exe" "$(cygpath -wa "${a}")"
}

function winmerge {
    local a b
    a=$1;shift
    b=$1;
    "$(cygpath -ma "$(scoop prefix winmerge)")/WinMergeU.exe" "$(cygpath -wa "${a}")" "$(cygpath -wa "${b}")"
}

function uuidgen {
    if command -v wsl >/dev/null 2>&1; then
        wsl uuidgen
        return
    fi
    if command -v ruby >/dev/null 2>&1; then
        ruby -rsecurerandom -e 'puts SecureRandom.uuid'
        return
    fi
}
