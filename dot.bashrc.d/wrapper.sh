open() {
    start "$(readlink -m $1)"
}
iview() {
    a=$1
    "/c/Users/y.okazawa/scoop/apps/irfanview/current/i_view64.exe" "$(cygpath -wa ${a})"
}
winmerge() {
    a=$1;shift
    b=$1;
    "/c/Users/y.okazawa/scoop/apps/winmerge/current/WinMergeU.exe" "$(cygpath -wa ${a})" "$(cygpath -wa ${b})"
}

alias vscode="/c/Users/y.okazawa/scoop/apps/vscode/current/Code.exe "

ksar() {
    "${HOME}/.ksar/kSar-5.0.6/run.sh" "$*"
}
