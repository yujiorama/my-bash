#!/bin/bash

function go-install {
    # https://tecadmin.net/install-go-on-debian/
    local version url
    if [[ 0 -ne $(id -u) ]]; then
        return
    fi

    if ! online dl.google.com 443; then
        return
    fi

    version="${1:-1.14}"
    url="https://dl.google.com/go/go${version}.linux-amd64.tar.gz"

    mkdir -p /usr/local/share
    download_new_file "${url}" "/usr/local/share/go${version}.tar.gz"
    if [[ -e "/usr/local/share/go${version}.tar.gz" ]]; then
        tar -C /usr/local/share -xzf "/usr/local/share/go${version}.tar.gz"
        find /usr/local/share/go/bin -type f | while read -r f; do
            /bin/ln -f -s "${f}" /usr/local/bin/"$(basename "${f}")"
        done
    fi
}

if ! command -v go >/dev/null 2>&1; then
    return
fi

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
