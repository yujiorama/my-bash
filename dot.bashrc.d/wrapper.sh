open() {
    start "$(readlink -m $1)"
}
iview() {
    a=$1
    "/c/Program Files/IrfanView/i_view64.exe" "$(cygpath -wa ${a})"
}
winmerge() {
    a=$1;shift
    b=$1;
    "/c/Program Files (x86)/WinMerge/WinMergeU.exe" "$(cygpath -wa ${a})" "$(cygpath -wa ${b})"
}
subl() {
    "/c/Program Files/Sublime Text 3/sublime_text.exe" $*
}
atom() {
    "${HOME}/AppData/Local/atom/bin/atom.cmd" $*
}
vscode() {
    "/c/Program Files/Microsoft VS Code/Code.exe" $*
}
heroku() {
    "/c/Program Files/Heroku/bin/heroku.cmd" $*
}
ksar() {
    "${HOME}/.ksar/kSar-5.0.6/run.sh" $*
}
ghqd() {
    local d="$(ghq root)/$(ghq list | peco)"
    [[ -d "${d}" ]] && pushd "${d}"
}
ghqv() {
    local d="$(ghq root)/$(ghq list | peco)"
    [[ -d "${d}" ]] && subl -a "${d}"
}
dc() {
    COMPOSE_CONVERT_WINDOWS_PATHS=1 docker-compose $*
}
