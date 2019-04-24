# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

open() {
    start "$(readlink -m $1)"
}
iview() {
    a=$1
    "/c/Users/y_okazawa/scoop/apps/irfanview/current/i_view64.exe" "$(cygpath -wa ${a})"
}
winmerge() {
    a=$1;shift
    b=$1;
    "/c/Users/y_okazawa/scoop/apps/winmerge/current/WinMergeU.exe" "$(cygpath -wa ${a})" "$(cygpath -wa ${b})"
}

alias vscode="/c/Users/y_okazawa/scoop/apps/vscode/current/Code.exe "
