PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -i -e 'go/' | tr '\n' ':')

if [[ -d "/c/tools/go" ]]; then
    export GOROOT
    GOROOT=/c/tools/go
    export GOPATH
    GOPATH=${HOME}/.go
    export GOBIN
    GOBIN=${GOPATH}/bin
    PATH=${PATH}:${GOROOT}/bin
    PATH=${PATH}:${GOBIN}
fi
