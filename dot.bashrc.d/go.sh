PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -i -e 'go/' | tr '\n' ':')

if [[ -d "/c/Go" ]]; then
    export GOROOT
    GOROOT=/c/Go
    export GOPATH
    GOPATH=${HOME}/.go
    export GOBIN
    GOBIN=${GOPATH}/bin
    PATH=${PATH}:${GOROOT}/bin
    PATH=${PATH}:${GOBIN}
fi

if ! which go 2>&1 >/dev/null; then
    return
fi

if alias | grep -w update_go_tool 2>&1 >/dev/null; then
    return
fi

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
update_go_tool github.com/mholt/archiver/cmd/arc &
update_go_tool github.com/schemalex/schemalex/cmd/schemadiff &
update_go_tool github.com/schemalex/schemalex/cmd/schemalex &
update_go_tool github.com/schemalex/schemalex/cmd/schemalint &
update_go_tool github.com/tsenart/vegeta &
update_go_tool bitbucket.org/yujiorama/docker-tag-search &

wait

if which ghq 2>&1 >/dev/null; then
    ghqd() {
        local d="$(ghq root)/$(ghq list | peco)"
        [[ -d "${d}" ]] && pushd "${d}"
    }
    ghqv() {
        local d="$(ghq root)/$(ghq list | peco)"
        [[ -d "${d}" ]] && subl -a "${d}"
    }
fi
