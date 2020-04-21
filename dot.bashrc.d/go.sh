#!/bin/bash

function go-install {
    if [[ "${OS}" != "Linux" ]]; then
        if command -v scoop >/dev/null 2>&1; then
            scoop install go
        fi
        return
    fi

    local version url
    # https://tecadmin.net/install-go-on-debian/
    if ! online dl.google.com 443; then
        return
    fi

    version="${1:-1.14}"
    url="https://dl.google.com/go/go${version}.linux-amd64.tar.gz"

    mkdir -p "${HOME}/share"

    download_new_file "${url}" "${HOME}/share/go${version}.tar.gz"
    if [[ -e "${HOME}/share/go${version}.tar.gz" ]]; then
        tar -C "${HOME}/share" -xzf "${HOME}/share/go${version}.tar.gz"
        find "${HOME}/share/go/bin" -type f | while read -r f; do
            /bin/ln -f -s "${f}" "${HOME}/bin/$(basename "${f}")"
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
        GO111MODULE=off go get -u "${src}"
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
