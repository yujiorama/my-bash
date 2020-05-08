#!/bin/bash
# skip: no

function ruby-install {
    if [[ "${OS}" != "Linux" ]]; then
        return
    fi

    if ! command -v git >/dev/null 2>&1; then
        return
    fi

    if ! online github.com 443; then
        return
    fi

    local version
    version="${1:-2.7.1}"

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

    if [[ ! -d "${RBENV_ROOT}" ]] || [[ ! -d "${RBENV_ROOT}/.git" ]]; then
        git clone https://github.com/rbenv/rbenv.git "${RBENV_ROOT}"
    else
        (cd "${RBENV_ROOT}" && git pull)
    fi
    if [[ ! -d "${RBENV_ROOT}" ]] || [[ ! -d "${RBENV_ROOT}/.git" ]]; then
        return
    fi

    mkdir -p "${RBENV_ROOT}/plugins"
    if [[ ! -d "${RBENV_ROOT}/plugins/ruby-build" ]] || [[ ! -d "${RBENV_ROOT}/plugins/ruby-build/.git" ]]; then
        git clone https://github.com/rbenv/ruby-build.git "${RBENV_ROOT}/plugins/ruby-build"
    else
        (cd "${RBENV_ROOT}/plugins/ruby-build" && git pull)
    fi
    if [[ ! -d "${RBENV_ROOT}/plugins/ruby-build" ]] || [[ ! -d "${RBENV_ROOT}/plugins/ruby-build/.git" ]]; then
        return
    fi

    (cd "${RBENV_ROOT}" && ./src/configure && make -C src)

    # shellcheck disable=SC1090
    source <("${RBENV_ROOT}/bin/rbenv" init -)

    if ! command -v rbenv >/dev/null 2>&1; then
        return
    fi

    if rbenv install --list | grep "${version}"; then
        rbenv install "${version}"
        rbenv local "${version}"
        rbenv global "${version}"

        rbenv rehash
        rbenv which ruby
        rbenv version

        # shellcheck disable=SC1090
        [[ -e "${MY_BASH_SOURCES}/ruby.env" ]] && source "${MY_BASH_SOURCES}/ruby.env"
        # shellcheck disable=SC1090
        [[ -e "${MY_BASH_SOURCES}/ruby.sh" ]] && source "${MY_BASH_SOURCES}/ruby.sh"
    fi

}

if [[ "${OS}" != "Linux" ]]; then

    if ! command -v ruby >/dev/null 2>&1; then
        return
    fi

    # shellcheck disable=SC2139
    alias be="$(dirname "$(command -v ruby)")/bundle.cmd exec "
    # shellcheck disable=SC2139
    alias bundle="$(dirname "$(command -v ruby)")/bundle.cmd "
fi

if [[ "${OS}" = "Linux" ]]; then

    if [[ -e "${RBENV_ROOT}/bin/rbenv" ]]; then
        # shellcheck disable=SC1090
        source <("${RBENV_ROOT}/bin/rbenv" init -)
    fi

    if ! command -v rbenv >/dev/null 2>&1; then
        return
    fi

    # shellcheck disable=SC2139
    alias be="$(rbenv which bundle) exec "
    # shellcheck disable=SC2139
    alias bundle="$(rbenv which bundle) "
fi
