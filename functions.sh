#!/bin/bash

function __here {
    if command -v cygpath >/dev/null 2>&1; then
        /bin/cygpath -wa "$PWD"
    else
        echo "$PWD"
    fi
}

function download_new_file {
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
    /bin/ls "${dst}"
}

function online {
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

function another_console_exists {
    local c
    c=$(/bin/ps -e | /bin/grep -c bash)
    (( c-- ))
    if [[ ${c} -eq 1 ]]; then
        return 1
    fi
    return 0
}


function mybash-cache-id {
    /usr/bin/find -L "${MY_BASH_SOURCES}" -type f \
    | /usr/bin/xargs -r /bin/cat \
    | /usr/bin/md5sum --binary - \
    | /usr/bin/cut -d ' ' -f 1
}

function mybash-cache-dir {
    local cacheid
    cacheid="$1"
    [[ -z "${cacheid}" ]] && cacheid="$(mybash-cache-id)"
    mkdir -p "${MY_BASH_CACHE}/${cacheid}"
    echo -n "${MY_BASH_CACHE}/${cacheid}"
}

function mybash-cache-init {
    local force
    force="$1"
    local cacheid
    cacheid="$(mybash-cache-id)"

    /usr/bin/find -L "${MY_BASH_CACHE}" -mindepth 1 -type d -not -name "${cacheid}" \
    | xargs -r /bin/rm -rf
    if [[ -n "${force}" ]]; then
        /usr/bin/find -L "${MY_BASH_CACHE}" -mindepth 1 -type d -name "${cacheid}" \
        | xargs -r /bin/rm -rf
    fi

    mybash-cache-dir "${cacheid}"
}

function mybash-cache-flush {
    local force
    force="$1"
    local cacheid
    cacheid="$(mybash-cache-id)"
    local cachedir
    cachedir="$(mybash-cache-dir "${cacheid}")"
    local cacheenv cachefunc
    cacheenv="${cachedir}/env"
    cachefunc="${cachedir}/func"
    if [[ -s "${cacheenv}" ]] && [[ -s "${cachefunc}" ]]; then
        return
    fi

    # shellcheck disable=SC2016
    /usr/bin/printenv \
    | /bin/grep -E -v '^(BASH.*|LS_COLORS|ORIGINAL.*|SSH_.*|SHELLOPTS|EUID|PPID|UID|PWD|F:)=' \
    | /bin/grep -E -v '^(_=|ConEmu.*=|!::=|CommonProgram.*=|COMMONPROGRAMFILES=|Program.*=|PROGRAMFILES=|asl.log=)' \
    | /bin/grep -E -v '^MY_BASH_.*=' \
    | while IFS='=' read -r key value; do
        echo "export ${key}=$(echo -n "${value}" | sed -E 's|([`$" ;\(\)])|\\\1|g')"
    done \
    | /usr/bin/sort -d \
    > "${cacheenv}"

    declare -f \
    | /bin/sed \
        -e 's|\(--!(no-\*)dir\*\))|"\1")|' \
        -e 's|\(--!(no-\*)@(file\|path)\*\))|"\1")|' \
        -e 's|\(--+(\[-a-z0-9_\])\))|"\1")|' \
        -e 's|\(-?(\\\[)+(\[a-zA-Z0-9?\])\))|"\1")|' \
    > "${cachefunc}"

    alias >> "${cachefunc}"

    /bin/ls -l "${cacheenv}" "${cachefunc}"
}

function mybash-reload-sources {
    local force
    force="$1"
    local cachedir
    cachedir="$(mybash-cache-init "${force}")"
    local cacheenv
    cacheenv="${cachedir}/env"
    # shellcheck disable=SC1090
    [[ -e "${cacheenv}" ]] && source "${cacheenv}"
    local cachefunc
    cachefunc="${cachedir}/func"
    # shellcheck disable=SC1090
    [[ -e "${cachefunc}" ]] && source "${cachefunc}"

    local sources
    sources=$(/usr/bin/find -L "${MY_BASH_SOURCES}" -type f -a -name \*.sh \
            | /usr/bin/sort -d)

    local f
    for f in ${sources}; do
        local stdout_log
        stdout_log=$(/bin/mktemp)
        local stderr_log
        stderr_log=$(/bin/mktemp)
        local starttime
        starttime=$SECONDS
        local laptime
        laptime=${starttime}

        echo -n "${f}"

        local ext
        for ext in "env" "sh"; do
            local ff
            ff="$(dirname "${f}")/$(basename "${f}" .sh).${ext}"
            if [[ ! -e "${ff}" ]]; then
                continue
            fi

            if [[ "sh" = "${ext}" ]]; then
                if [[ -e "${cacheenv}" ]]; then
                    if ! grep -E '^#\s*skip:\s*no$' "${ff}" >/dev/null 2>&1; then
                        echo -n "(skip)"
                        continue
                    fi
                fi

                # shellcheck source=/dev/null
                source "${ff}" 2>"${stderr_log}" >"${stdout_log}"
                continue
            fi

            local cachefile
            cachefile="${cachedir}/$(basename "${ff}")"

            if [[ -e "${cachefile}" ]]; then
                echo -n "(cached)"
                # shellcheck source=/dev/null
                source "${cachefile}"
            else
                local envbefore
                envbefore=$(mktemp)
                local envafter
                envafter=$(mktemp)
                /usr/bin/printenv | /usr/bin/sort > "${envbefore}"
                # shellcheck source=/dev/null
                source "${ff}" 2>"${stderr_log}" >"${stdout_log}"
                /usr/bin/printenv | /usr/bin/sort > "${envafter}"
                /usr/bin/diff --text --suppress-common-lines "${envbefore}" "${envafter}" \
                    | /bin/grep -E '^>' \
                    | /bin/sed -r \
                          -e "s|^> ([^=]+)=(.*)|export \1=\'\2\'|" \
                    > "${cachefile}"
                /bin/rm -f "${envbefore}" "${envafter}"
            fi
        done
        laptime=$(( SECONDS - starttime ))
        echo ": ${laptime} sec"
        if [[ -s ${stdout_log} ]]; then
            echo "=== stdout"; /bin/cat "${stdout_log}"; echo
        fi
        if [[ -s ${stderr_log} ]]; then
            echo "=== stderr"; /bin/cat "${stderr_log}"; echo
        fi
        /bin/rm -f "${stdout_log}" "${stderr_log}"
        if [[ -n "${MY_BASH_DEBUG}" ]]; then
            local no
            read -r -p "continue?[n] " no
            if [[ "n" = "${no:0:1}" ]] || [[ "N" = "${no:0:1}" ]]; then
                return
            fi
        fi
    done
}

function mybash-reload-env {
    # shellcheck disable=SC1090
    source <(/usr/bin/find "${MY_BASH_ENV}" -type f | xargs -r cat) >/dev/null
}

function mybash-reload-completion {
    # shellcheck disable=SC1090
    source <(/usr/bin/find "${MY_BASH_COMPLETION}" -type f | xargs -r cat) >/dev/null
}

function mybash-bin {

    /usr/bin/find "${MY_BASH_BIN}" -type f -exec /bin/rm -f {} \;

    local source_bin
    source_bin="$(/bin/readlink -m "${MY_BASH_SOURCES}/../bin")"
    /usr/bin/find "${source_bin}" -type f | while read -r f; do
        /bin/cp "${f}" "${MY_BASH_BIN}/$(basename "${f}")"
    done
    /usr/bin/find "${MY_BASH_BIN}" -ls
}

function mybash-secret-backup {
    if ! command -v rclone >/dev/null 2>&1; then
        return
    fi

    local prefix
    prefix="${1}"; shift
    [[ -z "${prefix}" ]] && prefix="$(hostname)"
    local rclone_flags
    rclone_flags="${RCLONE_FLAGS:-}"
    [[ -z "${rclone_flags}" ]] && rclone_flags="--progress --dry-run"

    local sources
    sources=(
        "${HOME}/gpg"
        "${HOME}/OpenVPN/config"
        "${HOME}/.gnupg"
        "${HOME}/.password-store"
        "${HOME}/.ssh"
        "${HOME}/.config"
        "${HOME}/.aws"
        "${HOME}/.azure"
        "${HOME}/AppData/Roaming/gcloud"
        "${HOME}/AppData/Roaming/terraform.rc"
    )
    local primary
    primary="dropbox"
    local secondary
    secondary="gdrive"

    local temporary
    temporary="$(mktemp -t -d mybash.XXXXX)"

    local remote_base
    remote_base="mybash/secret"

    local source
    for source in "${sources[@]}"; do
        local remote
        remote="${source#${HOME}/}"

        if [[ -d "${source}" ]]; then
            rclone mkdir "${temporary}/${prefix}/${remote}" >/dev/null 2>&1
            # shellcheck disable=SC2086
            rclone ${rclone_flags} sync --exclude ".tmp*/**" --exclude "cliextensions/**" "${source}" "${temporary}/${prefix}/${remote}"
        elif [[ -e "${source}" ]]; then
            # shellcheck disable=SC2086
            rclone ${rclone_flags} copy "${source}" "${temporary}/${prefix}/${remote}"
        else
            echo "skip ${source}"
        fi
    done

    rclone mkdir "${primary}:${remote_base}/${prefix}" >/dev/null 2>&1
    # shellcheck disable=SC2086
    rclone ${rclone_flags} sync "${temporary}/${prefix}" "${primary}:${remote_base}/${prefix}"
    rclone mkdir "${secondary}:${remote_base}/${prefix}" >/dev/null 2>&1
    # shellcheck disable=SC2086
    rclone ${rclone_flags} sync "${primary}:${remote_base}/${prefix}" "${secondary}:${remote_base}/${prefix}"

    echo "backup: ${primary}:${remote_base}/${prefix} (${secondary}:${remote_base}/${prefix})"
    rm -rf "${temporary}"
}

function mybash-secret-restore {
    if ! command -v rclone >/dev/null 2>&1; then
        return
    fi

    if [[ $# -lt 2 ]]; then
        return
    fi

    local prefix
    prefix="${1}"; shift
    [[ -z "${prefix}" ]] && prefix="$(hostname)"
    local destination
    destination="${1}"; shift
    [[ -z "${destination}" ]] && destination="$(mktemp -t -d mybash.XXXXX)"
    local rclone_flags
    rclone_flags="${RCLONE_FLAGS:-}"
    [[ -z "${rclone_flags}" ]] && rclone_flags="--progress --dry-run"

    local primary
    primary="dropbox"
    local secondary
    secondary="gdrive"

    local remote_base
    remote_base="mybash/secret"

    rclone mkdir "${destination}/${prefix}" >/dev/null 2>&1
    # shellcheck disable=SC2086
    rclone ${rclone_flags} sync "${primary}:${remote_base}/${prefix}" "${destination}/${prefix}"

    echo "restore: ${destination}/${prefix}"
    ls -la "${destination}/${prefix}"
}
