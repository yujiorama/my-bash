# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

# sudo mkdir -p /usr/local/share
# curl -fsSL https://dl.google.com/go/go1.12.linux-amd64.tar.gz | sudo tar -C /usr/local/share -xzf -
# for f in $(find /usr/local/share/go/bin -type f); do
#     sudo ln -f -s ${f} /usr/local/bin/$(basename ${f})
# done

if ! which go 2>&1 >/dev/null; then
    return
fi

export GOROOT
GOROOT=/usr/local/share/go

export GOPATH
mkdir -p ${HOME}/.go
GOPATH=${HOME}/.go

export PATH
PATH=${GOPATH}/bin:${GOROOT}/bin:${PATH}

go_update_tool() {
    go get -u \
        golang.org/x/tools/cmd/goimports \
        golang.org/x/tools/cmd/gotype \
        github.com/motemen/ghq \
        github.com/saibing/bingo \
        bitbucket.org/yujiorama/docker-tag-search \
        github.com/tsenart/vegeta
}

