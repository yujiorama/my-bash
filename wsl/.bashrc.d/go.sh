# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

# https://tecadmin.net/install-go-on-debian/
# 
# sudo mkdir -p /usr/local/share
# curl -fsSL https://dl.google.com/go/go1.12.linux-amd64.tar.gz | sudo tar -C /usr/local/share -xzf -
# for f in $(find /usr/local/share/go/bin -type f); do
#     sudo /bin/ln -f -s ${f} /usr/local/bin/$(basename ${f})
# done

export GOROOT
GOROOT=/usr/local/share/go

export GOPATH
mkdir -p "${HOME}/.go"
GOPATH=${HOME}/.go

export PATH
PATH=${GOPATH}/bin:${GOROOT}/bin:${PATH}


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


if [[ -n "${WSLENV}" ]]; then
    return
fi

update_go_tool golang.org/x/tools/cmd/goimports &
update_go_tool github.com/motemen/ghq &
update_go_tool github.com/tsenart/vegeta &
update_go_tool bitbucket.org/yujiorama/docker-tag-search &
update_go_tool bitbucket.org/yujiorama/tiny-nc &

wait
