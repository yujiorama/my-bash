#!/bin/bash

function __here {
    if command -v cygpath >/dev/null 2>&1; then
        /bin/cygpath -wa "$PWD"
    else
        echo "$PWD"
    fi
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
            mkdir -p "$(/usr/bin/dirname "${dst}")"
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

    if echo "${host}" | /bin/grep -E '[a-z]+://[a-zA-Z0-9_\.]+:[0-9]+' >/dev/null 2>&1; then

        schema="$(echo "${host}" | /usr/bin/cut -d ':' -f 1)"
        port="$(echo "${host}"   | /usr/bin/cut -d ':' -f 3)"
        host="$(echo "${host}"   | /usr/bin/cut -d ':' -f 2 | sed -e 's|//||g')"

    elif echo "${host}" | /bin/grep -E '[a-zA-Z0-9_\.]+:[0-9]+' >/dev/null 2>&1; then

        port="$(echo "${host}" | /usr/bin/cut -d ':' -f 2)"
        host="$(echo "${host}" | /usr/bin/cut -d ':' -f 1)"

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
    echo "${schema}://${host}:${port} status: ${rc}" >/dev/stderr
    return $rc
}
alias online='__online '

function __another_console_exists {
    local c
    c=$(/bin/ps -e | /bin/grep -c bash)
    (( c-- ))
    if [[ ${c} -eq 1 ]]; then
        return 1
    fi
    return 0
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
    sourcedir="$(/usr/bin/dirname "${BASH_SOURCE[0]}")"

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
        sources=$(/usr/bin/find -L "${sourcedir}" -type f -a \( -name \*.sh -o -name \*.env \) \
            | /usr/bin/sort -d \
            | /usr/bin/xargs -r /bin/grep -l "skip: no")
    else
        sources=$(/usr/bin/find -L "${sourcedir}" -type f -a \( -name \*.sh -o -name \*.env \) \
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
        echo -n "${f}: "
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
        echo "${laptime} sec${cached}"
        if [[ -s ${stdout_log} ]]; then
            echo "=== stdout"; /bin/cat "${stdout_log}"; echo
        fi
        if [[ -s ${stderr_log} ]]; then
            echo "=== stderr"; /bin/cat "${stderr_log}"; echo
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
