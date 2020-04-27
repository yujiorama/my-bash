#!/bin/bash

function go-install {
    hash -r
    if [[ "${OS}" != "Linux" ]]; then
        if command -v scoop >/dev/null 2>&1; then
            scoop install go
        fi
        return
    fi

    # https://tecadmin.net/install-go-on-debian/
    if ! online dl.google.com 443; then
        return
    fi

    local version
    version="${1:-1.14}"
    if command -v go >/dev/null 2>&1; then
        if [[ "go${version}" = "$(go version | cut -d ' ' -f 3)" ]]; then
            command -v go
            go version
            return
        fi
    fi

    local extprogram ext
    if command -v gzip >/dev/null 2>&1; then
        extprogram='gzip'
        ext='gz'
    fi

    local url
    url="https://dl.google.com/go/go${version}.linux-amd64.tar.${ext}"


    mkdir -p "${HOME}/tmp" "${HOME}/local/share/go/${version}" "${HOME}/local/bin"

    local tmpfile
    tmpfile="${HOME}/tmp/go${version}.tar.${ext}"

    download_new_file "${url}" "${tmpfile}"
    if [[ -e "${tmpfile}" ]]; then
        ${extprogram} -dc "${tmpfile}" \
        | tar -C "${HOME}/local/share/go/${version}" --strip-components 1 -xf -
        if [[ ! -d "${HOME}/local/share/go/${version}" ]]; then
            return
        fi

        local f
        find "${HOME}/local/share/go/${version}/bin" -type f | while read -r f; do
            /bin/ln -f -s "${f}" "${HOME}/local/bin/$(basename "${f}")"
        done

        hash -r
    fi

    command -v go
    go version

    if [[ "go${version}" = "$(go version | cut -d ' ' -f 3)" ]]; then
        rm -f "${tmpfile}"
    fi

    # shellcheck disable=SC1090
    [[ -e "${HOME}/.bashrc.d/go.env" ]] && source "${HOME}/.bashrc.d/go.env"
    # shellcheck disable=SC1090
    [[ -e "${HOME}/.bashrc.d/go.sh" ]] && source "${HOME}/.bashrc.d/go.sh"
}

if ! command -v go >/dev/null 2>&1; then
    return
fi

__update-go-tool()
{
    if ! command -v go >/dev/null 2>&1; then
        return
    fi
    local src name dst dsttime currenttime
    src=$1
    name=$(basename "${src}")
    dst="$(command -v "${name}" 2>/dev/null)"
    dsttime=0
    if [[ -e "${dst}" ]]; then
        dsttime=$(stat --format='%Y' "${dst}")
    fi
    currenttime=$(date --date="2 weeks ago" +"%s")
    if [[ ${dsttime} -lt ${currenttime} ]]; then
        go get -u "${src}"
    fi
}
alias update-go-tool='__update-go-tool'

for pkg in \
bitbucket.org/yujiorama/docker-tag-search \
bitbucket.org/yujiorama/tiny-nc \
github.com/mikefarah/yq/v3 \
github.com/visualfc/gocode \
github.com/x-motemen/ghq \
golang.org/x/lint \
golang.org/x/tools/cmd/goimports \
golang.org/x/tools/cmd/guru \
; do
    __update-go-tool ${pkg} &
done

wait

hash -r

if ! command -v fzf >/dev/null 2>&1; then
    if [[ "${OS}" = "Linux" ]]; then
        DEBIAN_FRONTEND=noninteractive apt install --yes --no-install-recommend --quiet fzf
    fi

    if [[ "${OS}" != "Linux" ]]; then
        if command -v scoop >/dev/null 2>&1; then
            scoop install fzf
        fi
    fi
fi

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
    fi
fi
