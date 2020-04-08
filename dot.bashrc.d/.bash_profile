#!/bin/bash

[[ -x c:/WINDOWS/system32/chcp.com ]] && c:/WINDOWS/system32/chcp.com 65001

umask 0022

# shellcheck source=/dev/null
[[ -e /bin/dircolors ]] && source <(/bin/dircolors --sh)

# shellcheck source=/dev/null
[[ -e "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"

export MSYS
MSYS=winsymlinks:nativestrict

export TERM
TERM=cygwin
export LANG
LANG=ja_JP.UTF-8
export LC_CTYPE
LC_CTYPE=${LANG}
export HOME
HOME=$(/bin/cygpath --unix "${USERPROFILE}")
export PAGER
PAGER='less -r -F'
export PATH
PATH=/bin:/usr/bin:/usr/bin/core_perl:/usr/bin/vendor_perl:/usr/local/bin:/usr/libexec:/mingw64/bin:/mingw64/libexec
export HERE_PS1
# shellcheck disable=SC2016
HERE_PS1='\[\e[35m\]\u@\h `__here`\[\e[0m\]\n$ '
export PS1
PS1=${HERE_PS1}

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

function __here {
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -wa "$PWD"
    else
        echo "$PWD"
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
    ctime=$(LANG=C date --utc --date="10 years ago" +"%a, %d %b %Y %H:%M:%S GMT")
    if [[ -e "${dst}" ]]; then
        ctime=$(LANG=C date --utc --date=@"$(stat --format='%Y' ${dst})" +"%a, %d %b %Y %H:%M:%S GMT")
    fi
    if command -v curl >/dev/null 2>&1; then
        local modified
        modified=$(
            curl -fsSL -I -H "If-Modified-Since: ${ctime}" -o /dev/null -w %\{http_code\} "${src}"
        )
        if [[ "200" = "${modified}" ]]; then
            curl -fsSL --output "${dst}" "${src}" >/dev/null 2>&1
        fi
    elif command -v http >/dev/null 2>&1; then
        http --follow --continue --download --output "${dst}" "${src}" >/dev/null 2>&1
    fi
    ls -l "${dst}"
}
alias download_new_file='__download_new_file '


function __online {
    local schema host port rc
    host="${1:-www.google.com}"
    port="${2:-80}"
    schema="tcp"

    if echo "${host}" | grep -E '[a-z]+://[a-zA-Z0-9_\.]+:[0-9]+' >/dev/null 2>&1; then

        schema="$(echo "${host}" | cut -d ':' -f 1)"
        port="$(echo "${host}"   | cut -d ':' -f 3)"
        host="$(echo "${host}"   | cut -d ':' -f 2 | sed -e 's|//||g')"

    elif echo "${host}" | grep -E '[a-zA-Z0-9_\.]+:[0-9]+' >/dev/null 2>&1; then

        port="$(echo "${host}" | cut -d ':' -f 2)"
        host="$(echo "${host}" | cut -d ':' -f 1)"

    else
        :
    fi
    
    rc=1
    if [[ -e "/usr/bin/nc" ]]; then
        /usr/bin/nc -vz --wait 1 "${host}" "${port}"
        rc=$?
    fi

    # go get -u bitbucket.org/yujiorama/tiny-nc
    if [[ -e "${HOME}/.go/bin/tiny-nc" ]]; then
        "${HOME}/.go/bin/tiny-nc" -timeout 1s "${host}" "${port}"
        rc=$?
    fi
    echo "${schema}://${host}:${port} status: ${rc}" >/dev/stderr
    return $rc
}
alias online='__online '

function __another_console_exists {
    local pid c
    pid=$$
    c=$(/bin/ps | /bin/grep bash | /bin/grep -c -v ${pid})
    if [[ ${c} -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}
alias another_console_exists='__another_console_exists '

sourcedir="$(dirname "${BASH_SOURCE[0]}")"
cachedir="${HOME}/.cache"
mkdir -p "${cachedir}"
cacheid=$(/usr/bin/find -L "${sourcedir}" -type f -name \*.env \
        | /bin/xargs -r /bin/cat \
        | /bin/md5sum --binary - \
        | /bin/cut -d ' ' -f 1)

/usr/bin/find -L "${cachedir}" -type f -not -name \*"-${cacheid}" | /bin/xargs -r /bin/rm -f

for f in $(/usr/bin/find -L "${sourcedir}" -type f | /bin/grep -v .bash_profile | /bin/sort); do
    stdout_log=$(/bin/mktemp)
    stderr_log=$(/bin/mktemp)
    /bin/echo -n "${f}: "
    starttime=$SECONDS
    cached_=""
    if [[ "env" = "${f##*.}" ]]; then
        cachefile_="${cachedir}/$(basename "${f}")-${cacheid}"
        if [[ -e "${cachefile_}" ]]; then
            cached_=" (cached)"
            # shellcheck source=/dev/null
            source "${cachefile_}"
        else
            envbefore=$(mktemp)
            envafter=$(mktemp)
            printenv | /bin/sort > "${envbefore}"
            # shellcheck source=/dev/null
            source "${f}" 2>"${stderr_log}" >"${stdout_log}"
            printenv | /bin/sort > "${envafter}"
            /bin/diff --text --suppress-common-lines "${envbefore}" "${envafter}" \
                | /bin/grep -E '^>' \
                | /bin/sed -r \
                      -e "s|^> ([^=]+)=(.*)|export \1=\'\2\'|" \
                > "${cachefile_}"
            /bin/rm -f "${envbefore}" "${envafter}"
        fi
    else
        # shellcheck source=/dev/null
        source "${f}" 2>"${stderr_log}" >"${stdout_log}"
    fi
    laptime=$(( SECONDS - starttime ))
    /bin/echo "${laptime} sec${cached_}"
    if [[ -s ${stdout_log} ]]; then
        /bin/echo "=== stdout"; /bin/cat "${stdout_log}"; /bin/echo
    fi
    if [[ -s ${stderr_log} ]]; then
        /bin/echo "=== stderr"; /bin/cat "${stderr_log}"; /bin/echo
    fi
    /bin/rm -f "${stdout_log}" "${stderr_log}"
done

echo "Startup Time: $SECONDS sec"
