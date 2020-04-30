#!/bin/bash

[[ -x c:/WINDOWS/system32/chcp.com ]] && c:/WINDOWS/system32/chcp.com 65001

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

export OS
[[ "$(/bin/uname)" = "Linux" ]] && OS="Linux"

export MSYS
MSYS=winsymlinks:nativestrict

# https://www.msys2.org/wiki/Porting/
# export MSYS_NO_PATHCONV
# MSYS_NO_PATHCONV=1
# export MSYS2_ARG_CNOV_EXCL
# MSYS2_ARG_CNOV_EXCL=1

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

if [[ "${OS}" = "Linux" ]]; then
    export TERM
    TERM="xterm-256color"
    export PATH
    PATH=/usr/local/sbin:/usr/local/bin:/usr/local/games:/usr/sbin:/usr/bin:/sbin:/bin
    PATH=${HOME}/local/sbin:${HOME}/local/bin:${HOME}/local/libexec:${PATH}
    PATH=${HOME}/bin:${HOME}/.local/bin:${PATH}
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
        if [[ -n "${ConEmuBaseDir}" ]] && [[ -d "${ConEmuBaseDir}" ]]; then
            /bin/cygpath --unix "$(/usr/bin/dirname "${ConEmuBaseDir}")"
            /bin/cygpath --unix "${ConEmuBaseDir}"
            /bin/cygpath --unix "${ConEmuBaseDir}/Scripts"
        fi
    } >> "${HOME}/.bash_path_suffix"


    if [[ -e "${HOME}/.bash_path_prefix" ]]; then
        PATH=$(/usr/bin/tr '\n' ':' < "${HOME}/.bash_path_prefix" | /bin/sed -e 's/::/:/g'):${PATH}
    fi

    if [[ -e "${HOME}/.bash_path_suffix" ]]; then
        PATH=${PATH}:$(/usr/bin/tr '\n' ':' < "${HOME}/.bash_path_suffix" | /bin/sed -e 's/::/:/g')
    fi
fi

# shellcheck source=/dev/null
[[ -e "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"

# shellcheck source=/dev/null
[[ -e "$(/usr/bin/dirname "${BASH_SOURCE[0]}")/.bash_functions" ]] && source "$(/usr/bin/dirname "${BASH_SOURCE[0]}")/.bash_functions"

cat - <<'EOS' > "${HOME}/.bash_logout"
if [ "$SHLVL" != 1 ]; then
    exit
fi

if another_console_exists; then
    exit
fi

[ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
[ -x /usr/bin/clear ]         && /usr/bin/clear

EOS

_reload_sources

echo "Startup Time: $SECONDS sec"
