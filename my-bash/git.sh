#!/bin/bash


function __git-latest-version {
    local source_dir
    source_dir="$1"

    local default_version
    default_version='v2.26.2'

    if [[ ! -d "${source_dir}" ]] || [[ ! -d "${source_dir}/.git" ]]; then
        echo -n "${default_version}"
        return
    fi

    if ! pushd "${source_dir}"; then
        echo -n "${default_version}"
        return
    fi

    local version
    version="$(git tag --sort verson:refname | tail -n 1)"
    [[ -z "${version}" ]] && version="${default_version}"

    echo -n "${version}"
}

function git-install {
    if [[ "${OS}" != "Linux" ]]; then
        return
    fi

    if ! command -v git >/dev/null 2>&1; then
        return
    fi

    local source_dir
    source_dir="${HOME}/src/git/git"
    mkdir -p "${source_dir}"

    local version
    version="${1:-$(__git-latest-version "${source_dir}")}"
    if command -v git >/dev/null 2>&1; then
        if [[ "${version}" = "$(git --version | cut -d ' ' -f 3)" ]]; then
            command -v git
            git --version
            return
        fi
    fi

    sudo apt install \
    --quiet \
    --no-install-recommends \
    --yes \
    build-essential libssl-dev zlib1g-dev libcurl4-openssl-dev libexpat1-dev tcl gettext make asciidoc xmlto

    if [[ ! -d "${source_dir}/.git" ]]; then
        git clone --quiet https://github.com/git/git "${source_dir}"
    fi

    pushd "${source_dir}" || return
    git fetch --prune
    git branch -D "${version}"
    git checkout -b "${version}" "refs/tags/${version}"
    popd || return

    make --quiet -C "${source_dir}" prefix="${HOME}/local" all doc
    make --quiet -C "${source_dir}" prefix="${HOME}/local" install install-doc

    hash -r

    command -v git
    git --version

    # shellcheck disable=SC1090
    [[ -e "${MY_BASH_SOURCES}/git.env" ]] && source "${MY_BASH_SOURCES}/git.env"
    # shellcheck disable=SC1090
    [[ -e "${MY_BASH_SOURCES}/git.sh" ]] && source "${MY_BASH_SOURCES}/git.sh"
}

if ! command -v git >/dev/null 2>&1; then
    return
fi

if [[ "${OS}" = "Linux" ]]; then
    PATH="${PATH}":$(readlink -m "$(git --exec-path)")

    if [[ -d "${HOME}/local/share/git/completion" ]]; then

        if [[ -e "${HOME}/local/share/git/completion/git-completion.bash" ]]; then
            cp "${HOME}/local/share/git/completion/git-completion.bash" "${MY_BASH_COMPLETION}/git"
        fi

        if [[ -e "${HOME}/local/share/git/completion/git-prompt.sh" ]]; then
            # shellcheck disable=SC1090
            source "${HOME}/local/share/git/completion/git-prompt.sh"
        fi
    fi

else
    PATH="${PATH}":$(cygpath -ua "$(git --exec-path)")
fi

mkdir -p "${HOME}/.git-templates" "${HOME}/man/man1"
download_new_file "https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets" "${HOME}/bin/git-secrets"
[[ -e "${HOME}/bin/git-secrets" ]] && chmod 755 "${HOME}/bin/git-secrets"
download_new_file "https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets.1" "${HOME}/man/man1/git-secrets.1"

echo run git secrets --install -f "${HOME}/.git-templates/git-secrets"
echo run git config --global init.templateDir "${HOME}/.git-templates/git-secrets"
echo run git secrets --register-aws --global

export MANPATH
MANPATH=${HOME}/man/man1:${MANPATH}
