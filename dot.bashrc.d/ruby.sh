#!/bin/bash

function ruby-install {
    local version
    version="${1:-2.7.1}"
    if [[ "${OS}" != "Linux" ]]; then
        return
    fi

    if ! command -v git >/dev/null 2>&1; then
        return
    fi

    if online github.com 443; then
        sudo apt install -y libssl-dev libreadline-dev zlib1g-dev
        git clone https://github.com/rbenv/rbenv.git "${HOME}/.rbenv"
        (cd "${HOME}/.rbenv" && ./src/configure && make -C src)

        # shellcheck disable=SC1090
        source "${HOME}/.bashrc.d/ruby.sh"

        mkdir -p "$(rbenv root)"/plugins
        git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
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
