#!/bin/bash

umask 0022

/bin/stty -ixon

shopt -s cdspell
shopt -s checkjobs
shopt -s checkwinsize
shopt -s cmdhist
shopt -s direxpand
shopt -s dirspell
shopt -s histappend
shopt -s interactive_comments

export MSYS
MSYS=winsymlinks:nativestrict
# https://www.msys2.org/wiki/Porting/
# export MSYS_NO_PATHCONV
# MSYS_NO_PATHCONV=1
# export MSYS2_ARG_CNOV_EXCL
# MSYS2_ARG_CNOV_EXCL=1

export OS
[[ "$(/bin/uname)" = "Linux" ]] && OS="Linux"
export LANG
LANG="ja_JP.UTF-8"
export LANGUAGE
LANGUAGE="ja_JP:jp"
export LC_CTYPE
LC_CTYPE="${LANG}"
export PAGER
PAGER='less -r -F'
export EDITOR
EDITOR="$(/usr/bin/which vi)"

export MY_BASH_SOURCES
MY_BASH_SOURCES="$(/usr/bin/dirname "${BASH_SOURCE[0]}")/my-bash"

export MY_BASH_BIN
MY_BASH_BIN="${HOME}/.config/my-bash/bin"
/bin/mkdir -p "${MY_BASH_BIN}"

export MY_BASH_LOGOUT
MY_BASH_LOGOUT="${HOME}/.config/my-bash/logout"
/bin/mkdir -p "${MY_BASH_LOGOUT}"

export MY_BASH_CACHE
MY_BASH_CACHE="${HOME}/.config/my-bash/cache"
/bin/mkdir -p "${MY_BASH_CACHE}"

export MY_BASH_COMPLETION
MY_BASH_COMPLETION="${HOME}/.config/my-bash/completion"
/bin/mkdir -p "${MY_BASH_COMPLETION}"

export MY_BASH_ENV
MY_BASH_ENV="${HOME}/.config/my-bash/env"
/bin/mkdir -p "${MY_BASH_ENV}"

export MY_BASH_APP
MY_BASH_APP="${HOME}/.config/my-bash/app"
/bin/mkdir -p "${MY_BASH_APP}"

export MY_BASH_DEBUG
MY_BASH_DEBUG="${MY_BASH_DEBUG:-}"

if [[ "${OS}" = "Linux" ]]; then
    export TERM
    TERM="xterm-256color"
    export USERPROFILE
    USERPROFILE="${HOME}"
    export PATH
    PATH=/usr/local/sbin:/usr/local/bin:/usr/local/games:/usr/sbin:/usr/bin:/sbin:/bin
    PATH=${HOME}/local/sbin:${HOME}/local/bin:${HOME}/local/libexec:${PATH}
    PATH=${HOME}/bin:${HOME}/.local/bin:${PATH}
    PATH=${MY_BASH_BIN}:${PATH}
    PATH=${PATH}:/mnt/c/Windows:/mnt/c/Windows/System32
fi

if [[ "${OS}" != "Linux" ]]; then
    export TERM
    TERM="cygwin"
    export HOME
    HOME=$(/bin/cygpath --unix "${HOME:-${USERPROFILE}}")
    export PATH
    PATH=/bin:/usr/bin:/usr/bin/core_perl:/usr/bin/vendor_perl:/usr/libexec
    PATH=/mingw64/bin:/mingw64/libexec:${PATH}

    /bin/rm -f "${HOME}/.bash_path_suffix" "${HOME}/.bash_path_prefix"

    {
        /bin/cygpath --unix "${MY_BASH_BIN}";
        /bin/cygpath --unix "${HOME}/bin";
        [[ -d "${HOME}/scoop/shims" ]] && \
            echo "${HOME}/scoop/shims";
        [[ -d "/c/ProgramData/chocoportable/bin" ]] && \
            echo "/c/ProgramData/chocoportable/bin";
        [[ -d "/c/ProgramData/chocolatey/bin" ]] && \
            echo "/c/ProgramData/chocolatey/bin";
    } >> "${HOME}/.bash_path_prefix"

    {
        echo "/c/WINDOWS";
        echo "/c/WINDOWS/system32";
        echo "/c/WINDOWS/System32/Wbem";
        echo "/c/WINDOWS/System32/WindowsPowerShell/v1.0";
    } >> "${HOME}/.bash_path_suffix"


    if [[ -e "${HOME}/.bash_path_prefix" ]]; then
        PATH=$(/usr/bin/tr '\n' ':' < "${HOME}/.bash_path_prefix" | /bin/sed -e 's/::/:/g'):${PATH}
    fi

    if [[ -e "${HOME}/.bash_path_suffix" ]]; then
        PATH=${PATH}:$(/usr/bin/tr '\n' ':' < "${HOME}/.bash_path_suffix" | /bin/sed -e 's/::/:/g')
    fi
fi

# shellcheck disable=SC1090
[[ -e "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"

# shellcheck disable=SC1090
[[ -e "${MY_BASH_SOURCES}/functions" ]] && source "${MY_BASH_SOURCES}/functions"

echo "== mybash-reload-sources"
mybash-reload-sources

echo "== mybash-reload-env"
mybash-reload-env

echo "== mybash-reload-completion"
mybash-reload-completion

echo "== mybash-cache-flush"
mybash-cache-flush

echo "== mybash-bin"
mybash-bin

/bin/cat - <<'EOS' > "${HOME}/.bash_logout"
if [ "$SHLVL" != 1 ]; then
    exit
fi

if another_console_exists; then
    exit
fi

[ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
[ -x /usr/bin/clear ]         && /usr/bin/clear

for f in $(/usr/bin/find "${MY_BASH_LOGOUT}" -type f); do
    source "${f}"
done
EOS

echo "== Startup Time: $SECONDS sec"
