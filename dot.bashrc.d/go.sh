# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if which ghq >/dev/null 2>&1; then
    if which fzf >/dev/null 2>&1; then
        ghqd() {
            local d="$(ghq root)/$(ghq list | fzf)"
            [[ -d "${d}" ]] && pushd "${d}"
        }
        ghqv() {
            local d="$(ghq root)/$(ghq list | fzf)"
            [[ -d "${d}" ]] && subl -a "${d}"
        }
    elif which peco >/dev/null 2>&1; then
        ghqd() {
            local d="$(ghq root)/$(ghq list | peco)"
            [[ -d "${d}" ]] && pushd "${d}"
        }
        ghqv() {
            local d="$(ghq root)/$(ghq list | peco)"
            [[ -d "${d}" ]] && subl -a "${d}"
        }
    fi
fi
