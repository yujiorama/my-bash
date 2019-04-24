# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -i -e 'go/' | tr '\n' ':')

if ! which go >/dev/null 2>&1; then
    return
fi

export GOPATH
GOPATH=${HOME}/.go
export GOBIN
GOBIN=${GOPATH}/bin
export GOROOT
GOROOT=$(cygpath -u $(go env -json | jq -r .GOROOT))
export PATH
PATH=${PATH}:${GOROOT}/bin:${GOBIN}

__update_go_tool()
{
    local src=$1
    local name=$(basename ${src})
    local dst="$(which ${name} 2>/dev/null)"
    local dsttime=0
    if [[ -e "${dst}" ]]; then
        dsttime=$(stat --format='%Y' ${dst})
    fi
    local currenttime=$(date --date="2 weeks ago" +"%s")
    if [[ ${dsttime} -lt ${currenttime} ]]; then
        local domain=$(echo ${src} | cut -d '/' -f 1)
        local port=443
        if online ${domain} ${port}; then
            go get -u ${src}
        fi
    fi
}
alias update_go_tool='__update_go_tool'

update_go_tool golang.org/x/tools/cmd/goimports &
update_go_tool golang.org/x/tools/cmd/gotype &
update_go_tool github.com/motemen/ghq &
update_go_tool github.com/saibing/bingo &
update_go_tool github.com/tsenart/vegeta &
update_go_tool bitbucket.org/yujiorama/docker-tag-search &
update_go_tool bitbucket.org/yujiorama/tiny-nc &

wait

if which ghq >/dev/null 2>&1; then
    ghqd() {
        local d="$(ghq root)/$(ghq list | peco)"
        [[ -d "${d}" ]] && pushd "${d}"
    }
    ghqv() {
        local d="$(ghq root)/$(ghq list | peco)"
        [[ -d "${d}" ]] && subl -a "${d}"
    }
fi
