# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

__update-go-tool()
{
    local src name dst dsttime currenttime
    if ! command -v go >/dev/null 2>&1; then
        return
    fi
    src=$1
    name=$(basename "${src}")
    dst="$(command -v "${name}" 2>/dev/null)"
    dsttime=0
    if [[ -e "${dst}" ]]; then
        dsttime=$(stat --format='%Y' "${dst}")
    fi
    currenttime=$(date --date="2 weeks ago" +"%s")
    if [[ ${dsttime} -lt ${currenttime} ]]; then
        (cd "${HOME}" && go get -u "${src}")
    fi
}
alias update-go-tool='__update-go-tool'

update-go-tool golang.org/x/tools/cmd/goimports &
update-go-tool github.com/x-motemen/ghq &
update-go-tool github.com/mikefarah/yq/v3 &
update-go-tool bitbucket.org/yujiorama/docker-tag-search &
update-go-tool bitbucket.org/yujiorama/tiny-nc &
update-go-tool github.com/golang/lint &
update-go-tool github.com/visualfc/gocode &
update-go-tool golang.org/x/tools/cmd/guru &

wait

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
