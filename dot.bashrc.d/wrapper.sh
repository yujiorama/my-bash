# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

open() {
    start "$(readlink -m "$1")"
}
iview() {
    local a=$1
    "$(cygpath -ma "$(scoop prefix irfanview)")/i_view64.exe" "$(cygpath -wa "${a}")"
}
winmerge() {
	local a b
    a=$1;shift
    b=$1;
    "$(cygpath -ma "$(scoop prefix winmerge)")/WinMergeU.exe" "$(cygpath -wa "${a}")" "$(cygpath -wa "${b}")"
}

alias vscode="$(cygpath -ma "$(scoop prefix vscode)")/Code.exe "
