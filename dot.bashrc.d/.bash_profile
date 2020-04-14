#!/bin/bash

[[ -x c:/WINDOWS/system32/chcp.com ]] && c:/WINDOWS/system32/chcp.com 65001

umask 0022

# shellcheck source=/dev/null
[[ -e "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"

export MSYS
MSYS=winsymlinks:nativestrict

# https://www.msys2.org/wiki/Porting/
# export MSYS_NO_PATHCONV
# MSYS_NO_PATHCONV=1
# export MSYS2_ARG_CNOV_EXCL
# MSYS2_ARG_CNOV_EXCL=1

export TERM
TERM=cygwin
export LANG
LANG=ja_JP.UTF-8
export LC_CTYPE
LC_CTYPE=${LANG}
export PAGER
PAGER='less -r -F'
export HERE_PS1
# shellcheck disable=SC2016
HERE_PS1='\[\e[35m\]\u@\h `__here`\[\e[0m\]\n$ '
export PS1
PS1=${HERE_PS1}
export OS
[[ "$(uname)" = "Linux" ]] && OS="Linux"

if [[ "${OS}" = "Linux" ]]; then
    export PATH
    PATH=/usr/local/sbin:/usr/local/bin:/usr/local/games:/usr/sbin:/usr/bin:/sbin:/bin
    PATH=${HOME}/bin:${HOME}/.local/bin:${PATH}
    PATH=${PATH}:/mnt/c/Windows:/mnt/c/Windows/System32
fi

if [[ "${OS}" != "Linux" ]]; then
    export HOME
    HOME=$(/bin/cygpath --unix "${USERPROFILE}")
    export PATH
    PATH=/bin:/usr/bin:/usr/bin/core_perl:/usr/bin/vendor_perl:/usr/local/bin:/usr/libexec:/mingw64/bin:/mingw64/libexec
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
            /bin/cygpath --unix "$(dirname "${ConEmuBaseDir}")"
            /bin/cygpath --unix "${ConEmuBaseDir}"
            /bin/cygpath --unix "${ConEmuBaseDir}/Scripts"
        fi
    } >> "${HOME}/.bash_path_suffix"


    if [[ -e "${HOME}/.bash_path_prefix" ]]; then
        PATH=$(/bin/tr '\n' ':' < "${HOME}/.bash_path_prefix" | /bin/sed -e 's/::/:/g'):${PATH}
    fi

    if [[ -e "${HOME}/.bash_path_suffix" ]]; then
        PATH=${PATH}:$(/bin/tr '\n' ':' < "${HOME}/.bash_path_suffix" | /bin/sed -e 's/::/:/g')
    fi
fi

function __here {
    if command -v cygpath >/dev/null 2>&1; then
        /bin/cygpath -wa "$PWD"
    else
        /bin/echo "$PWD"
    fi
}

function prompt-here {
    PS1=$HERE_PS1
}

function prompt-msys {
    PS1=$MSYS2_PS1
}


function __download_new_file {
    local src dst ctime
    src=$1
    dst=$2
    ctime=$(LANG=C /bin/date --utc --date="10 years ago" +"%a, %d %b %Y %H:%M:%S GMT")
    if [[ -e "${dst}" ]]; then
        ctime=$(LANG=C /bin/date --utc --date=@"$(/usr/bin/stat --format='%Y' "${dst}")" +"%a, %d %b %Y %H:%M:%S GMT")
    fi
    if command -v curl >/dev/null 2>&1; then
        local modified
        modified=$(
            curl -fsSL -I -H "If-Modified-Since: ${ctime}" -o /dev/null -w %\{http_code\} "${src}"
        )
        if [[ "200" = "${modified}" ]]; then
            mkdir -p "$(dirname "${dst}")"
            curl -fsSL --output "${dst}" "${src}" >/dev/null 2>&1
        fi
    elif command -v http >/dev/null 2>&1; then
        http --follow --continue --download --output "${dst}" "${src}" >/dev/null 2>&1
    fi
    /bin/ls -l "${dst}"
}
alias download_new_file='__download_new_file '


function __online {
    local schema host port rc
    host="${1:-www.google.com}"
    port="${2:-80}"
    schema="tcp"

    if /bin/echo "${host}" | /bin/grep -E '[a-z]+://[a-zA-Z0-9_\.]+:[0-9]+' >/dev/null 2>&1; then

        schema="$(/bin/echo "${host}" | /usr/bin/cut -d ':' -f 1)"
        port="$(/bin/echo "${host}"   | /usr/bin/cut -d ':' -f 3)"
        host="$(/bin/echo "${host}"   | /usr/bin/cut -d ':' -f 2 | sed -e 's|//||g')"

    elif /bin/echo "${host}" | /bin/grep -E '[a-zA-Z0-9_\.]+:[0-9]+' >/dev/null 2>&1; then

        port="$(/bin/echo "${host}" | /usr/bin/cut -d ':' -f 2)"
        host="$(/bin/echo "${host}" | /usr/bin/cut -d ':' -f 1)"

    else
        :
    fi
    
    rc=1
    if [[ -e "/bin/nc" ]]; then
        /bin/nc -vz -w 1 "${host}" "${port}"
        rc=$?
    fi

    # go get -u bitbucket.org/yujiorama/tiny-nc
    if [[ -e "${HOME}/.go/bin/tiny-nc" ]]; then
        "${HOME}/.go/bin/tiny-nc" -timeout 1s "${host}" "${port}"
        rc=$?
    fi
    /bin/echo "${schema}://${host}:${port} status: ${rc}" >/dev/stderr
    return $rc
}
alias online='__online '

function __another_console_exists {
    local pid c
    if [[ "Linux" = "$(uname)" ]]; then
        return 0
    fi
    pid=$$
    c=$(/bin/ps | /bin/grep bash | /bin/grep -c -v ${pid})
    if [[ ${c} -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}
alias another_console_exists='__another_console_exists '

function cache-flush {
    local cacheenv cachefunc
    cacheenv="$1"
    if [[ -z "${cacheenv}" ]]; then
        cacheenv="$(find "${HOME}/.cache" -type f -name .env-\* | head -n 1)"
    fi
    if [[ -z "${cacheenv}" ]]; then
        return
    fi
    cachefunc="$2"
    if [[ -z "${cachefunc}" ]]; then
        cachefunc="$(find "${HOME}/.cache" -type f -name .func-\* | head -n 1)"
    fi
    if [[ -z "${cachefunc}" ]]; then
        return
    fi

    # shellcheck disable=SC2016
    /usr/bin/printenv \
    | /bin/grep -E -v '^(BASH.*|LS_COLORS|ORIGINAL.*|SSH_.*|SHELLOPTS|EUID|PPID|UID|PWD)=' \
    | /bin/grep -E -v '^(_=|ConEmu.*=|!::=|CommonProgram.*=|COMMONPROGRAMFILES=|Program.*=|PROGRAMFILES=|asl.log=)' \
    | while IFS='=' read -r key value; do
        echo "export ${key}=$(echo -n "${value}" | sed -E 's|([`$" ;\(\)])|\\\1|g')"
    done \
    | /usr/bin/sort -d \
    > "${cacheenv}"

    declare -f \
    | /bin/sed -e 's|\(--!(no-\*)dir\*\))|"\1")|' \
               -e 's|\(--!(no-\*)@(file\|path)\*\))|"\1")|' \
               -e 's|\(--+(\[-a-z0-9_\])\))|"\1")|' \
               -e 's|\(-?(\\\[)+(\[a-zA-Z0-9?\])\))|"\1")|' \
    > "${cachefunc}"

    alias >> "${cachefunc}"
}

function _reload_sources {

    local sourcedir completiondir cachedir cacheid
    sourcedir="$(dirname "${BASH_SOURCE[0]}")"

    completiondir="${HOME}/.completion"
    mkdir -p "${completiondir}"

    cachedir="${HOME}/.cache"
    mkdir -p "${cachedir}"

    cacheid=$(/usr/bin/find -L "${sourcedir}" -type f \
            | /usr/bin/xargs -r /bin/cat \
            | /usr/bin/md5sum --binary - \
            | /usr/bin/cut -d ' ' -f 1)

    /usr/bin/find -L "${cachedir}" -type f -not -name \*"-${cacheid}" | /usr/bin/xargs -r /bin/rm -f

    local cacheenv cachefunc
    cacheenv="${cachedir}/.env-${cacheid}"
    cachefunc="${cachedir}/.func-${cacheid}"

    local sources
    if [[ -e "${cacheenv}" ]]; then
        sources=$(/usr/bin/find -L "${sourcedir}" -type f \
            | /bin/grep -v "$(basename "${BASH_SOURCE[0]}")" \
            | /usr/bin/sort -d \
            | /usr/bin/xargs -r /bin/grep -l "skip: no")
    else
        sources=$(/usr/bin/find -L "${sourcedir}" -type f \
            | /bin/grep -v "$(basename "${BASH_SOURCE[0]}")" \
            | /usr/bin/sort -d)
    fi

    if [[ -e "${cacheenv}" ]]; then
        # shellcheck disable=SC1090
        source "${cacheenv}"
        # shellcheck disable=SC1090
        source "${cachefunc}"
    fi

    local f
    for f in ${sources}; do
        local stdout_log stderr_log starttime laptime cached
        stdout_log=$(/bin/mktemp)
        stderr_log=$(/bin/mktemp)
        /bin/echo -n "${f}: "
        starttime=$SECONDS
        laptime=${starttime}
        cached=""
        if [[ "env" = "${f##*.}" ]]; then
            local cachefile envbefore envafter
            cachefile="${cachedir}/$(basename "${f}")-${cacheid}"
            if [[ -e "${cachefile}" ]]; then
                cached=" (cached)"
                # shellcheck source=/dev/null
                source "${cachefile}"
            else
                envbefore=$(mktemp)
                envafter=$(mktemp)
                /usr/bin/printenv | /usr/bin/sort > "${envbefore}"
                # shellcheck source=/dev/null
                source "${f}" 2>"${stderr_log}" >"${stdout_log}"
                /usr/bin/printenv | /usr/bin/sort > "${envafter}"
                /usr/bin/diff --text --suppress-common-lines "${envbefore}" "${envafter}" \
                    | /bin/grep -E '^>' \
                    | /bin/sed -r \
                          -e "s|^> ([^=]+)=(.*)|export \1=\'\2\'|" \
                    > "${cachefile}"
                /bin/rm -f "${envbefore}" "${envafter}"
            fi
        else
            # shellcheck source=/dev/null
            source "${f}" 2>"${stderr_log}" >"${stdout_log}"
        fi
        laptime=$(( SECONDS - starttime ))
        /bin/echo "${laptime} sec${cached}"
        if [[ -s ${stdout_log} ]]; then
            /bin/echo "=== stdout"; /bin/cat "${stdout_log}"; /bin/echo
        fi
        if [[ -s ${stderr_log} ]]; then
            /bin/echo "=== stderr"; /bin/cat "${stderr_log}"; /bin/echo
        fi
        /bin/rm -f "${stdout_log}" "${stderr_log}"
        if [[ -n "${DEBUG}" ]]; then
            local no
            read -r -p "continue?[n] " no
            if [[ "n" = "${no:0:1}" ]] || [[ "N" = "${no:0:1}" ]]; then
                return
            fi
        fi
    done

    if [[ ! -e "${cacheenv}" ]]; then
        cache-flush "${cacheenv}" "${cachefunc}"
    fi

    for f in $(/usr/bin/find "${completiondir}" -type f); do
        # shellcheck disable=SC1090
        source "${f}" >/dev/null 2>&1
    done
}

_reload_sources

echo "Startup Time: $SECONDS sec"
