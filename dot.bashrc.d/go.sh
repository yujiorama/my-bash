# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if command -v ghq >/dev/null 2>&1; then
    if command -v fzf >/dev/null 2>&1; then
        ghqd() {
            d="$(ghq root)/$(ghq list | fzf)"
            [[ "${d}" != "$(ghq root)" ]] && pushd "${d}" || exit
        }
        ghqv() {
            d="$(ghq root)/$(ghq list | fzf)"
            [[ "${d}" != "$(ghq root)" ]] && subl -a "${d}"
        }
    elif command -v peco >/dev/null 2>&1; then
        ghqd() {
            d="$(ghq root)/$(ghq list | peco)"
            [[ "${d}" != "$(ghq root)" ]] && pushd "${d}" || exit
        }
        ghqv() {
            d="$(ghq root)/$(ghq list | peco)"
            [[ "${d}" != "$(ghq root)" ]] && subl -a "${d}"
        }
    fi
fi
