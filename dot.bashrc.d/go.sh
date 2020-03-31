# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

__update_go_tool()
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
alias update_go_tool='__update_go_tool'

update_go_tool golang.org/x/tools/cmd/goimports &
update_go_tool github.com/x-motemen/ghq &
update_go_tool github.com/tsenart/vegeta &
update_go_tool github.com/mikefarah/yq/v3 &
update_go_tool bitbucket.org/yujiorama/docker-tag-search &
update_go_tool bitbucket.org/yujiorama/tiny-nc &

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
