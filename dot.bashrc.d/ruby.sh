#!/bin/bash

function ruby-install {
    if [[ "${OS}" != "Linux" ]]; then
        return
    fi

    local version
    version="${1:-2.7.1}"

    if ! command -v git >/dev/null 2>&1; then
        return
    fi

    if ! online github.com 443; then
        return
    fi

    sudo apt install -y \
        libssl-dev \
        libreadline-dev \
        zlib1g-dev \
        libyaml-dev \
        libreadline-dev \
        libncurses5-dev \
        libffi-dev \
        libgdbm-dev \
        autoconf \
        bison \
        build-essential

    if [[ ! -d "${HOME}/.rbenv" ]] || [[ ! -d "${HOME}/.rbenv/.git" ]]; then
        git clone https://github.com/rbenv/rbenv.git "${HOME}/.rbenv"
    else
        (cd "${HOME}/.rbenv" && git pull)
    fi
    if [[ ! -d "${HOME}/.rbenv" ]] || [[ ! -d "${HOME}/.rbenv/.git" ]]; then
        return
    fi
    (cd "${HOME}/.rbenv" && ./src/configure && make -C src)

    # shellcheck disable=SC1090
    source <("${HOME}/.rbenv/bin/rbenv" init -)

    mkdir -p "$(rbenv root)"/plugins
    if [[ ! -d "$(rbenv root)/plugins/ruby-build" ]]; then
        git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    else
        (cd "$(rbenv root)/plugins/ruby-build" && git pull)
    fi

    if rbenv install --list | grep "${version}"; then
        rbenv install "${version}"
        rbenv local "${version}"
        rbenv global "${version}"
    fi
}

if ! command -v ruby >/dev/null 2>&1; then
    return
fi

if command -v rbenv >/dev/null 2>&1; then
    # shellcheck disable=SC1090
    source <(rbenv init -)
fi

if command -v bundle >/dev/null 2>&1; then
    alias be='bundle exec '
fi

if command -v bundle.cmd >/dev/null 2>&1; then
    # shellcheck disable=SC2139
    alias be="$(command -v bundl.cmd) exec "
    # shellcheck disable=SC2139
    alias bundle="$(command -v bundl.cmd) "
fi
