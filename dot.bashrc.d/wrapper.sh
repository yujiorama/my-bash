#!/bin/bash

if [[ "${OS}" != "Linux" ]]; then
    function open {
        start "$(readlink -m "$1")"
    }

    function iview {
        local a=$1
        start "$(cygpath -ma "$(scoop prefix irfanview)")/i_view64.exe" "$(cygpath -wa "${a}")"
    }

    function winmerge {
        local a b
        a=$1;shift
        b=$1;
        start "$(cygpath -ma "$(scoop prefix winmerge)")/WinMergeU.exe" "$(cygpath -wa "${a}")" "$(cygpath -wa "${b}")"
    }

    function gcviewer {
        local app_name dir_name jar_name jar_path url
        app_name="${FUNCNAME[0]}"
        jar_name="${app_name}.jar"
        dir_name="${HOME}/.${app_name}"
        if [[ ! -d "${dir_name}" ]]; then
            mkdir -p "${dir_name}"
        fi
        jar_path=$(cygpath -wa "${dir_name}/${jar_name}")

        url="https://maven.apache.org/maven2/com/github/chewiebug/gcviewer/1.35/gcviewer-1.35.jar"

        download_new_file "${url}" "${jar_path}"

        "${JAVA_HOME}/bin/java" -jar "${jar_path}" "$@"
    }

    function stream2es {
        local app_name dir_name jar_name jar_path url
        app_name="${FUNCNAME[0]}"
        jar_name="${app_name}.jar"
        dir_name="${HOME}/.${app_name}"
        if [[ ! -d "${dir_name}" ]]; then
            mkdir -p "${dir_name}"
        fi
        jar_path=$(cygpath -wa "${dir_name}/${jar_name}")

        url="https://download.elasticsearch.org/stream2es/stream2es"

        download_new_file "${url}" "${jar_path}"

        "${JAVA_HOME}/bin/java" -jar "${jar_path}" "$@"
    }

    function dbxcli {
        local app_name dir_name exe_name exe_path url
        app_name="${FUNCNAME[0]}"
        exe_name="${app_name}.exe"
        dir_name="${HOME}/.${app_name}"
        if [[ ! -d "${dir_name}" ]]; then
            mkdir -p "${dir_name}"
        fi
        exe_path=$(cygpath -wa "${dir_name}/${exe_name}")

        if [[ ! -x "${exe_path}" ]]; then

          url="$(curl -fsSL --header 'Accept: application/json' https://api.github.com/repos/dropbox/dbxcli/releases \
          | jq -r '
              max_by(.name) |
              .name as $version |
              .assets[] |
              select(.name | contains("windows")) |
              .browser_download_url')"

          download_new_file "${url}" "${exe_path}"

        fi

        ${exe_path} "$@"
    }
fi

if [[ "${OS}" = "Linux" ]]; then
    function open {
        explorer.exe "$1"
    }

    function subl {
        local wsl_file windows_file
        wsl_file=$1
        if [[ ! -e ${wsl_file} ]]; then
            touch "${wsl_file}"
        fi
        if ! mountpoint -q "$(readlink -f "${wsl_file}" | cut -d '/' -f 1,2,3,4)"; then
            return
        fi
        windows_file="$(wslpath -m "${HOST_USER_HOME}"/"$(readlink -f "${wsl_file}")")"
        "${HOST_USER_HOME}/scoop/shims/subl.exe" "${windows_file}"
    }

    function code {
        local wsl_file windows_file
        wsl_file=$1
        if [[ ! -e ${wsl_file} ]]; then
            touch "${wsl_file}"
        fi
        if ! mountpoint -q "$(readlink -f "${wsl_file}" | cut -d '/' -f 1,2,3,4)"; then
            return
        fi
        windows_file="$(wslpath -m "${HOST_USER_HOME}"/"$(readlink -f "${wsl_file}")")"
        "${HOST_USER_HOME}/scoop/shims/code.exe" ${windows_file}
    }
fi

function uuidgen {
    if ! command -v ruby >/dev/null 2>&1; then
        return
    fi

    ruby -rsecurerandom -e 'puts SecureRandom.uuid'
}

function urlencode {
    if ! command -v ruby >/dev/null 2>&1; then
        return
    fi

    local uri="$1"
    ruby -ruri -e "puts URI.parse('$uri').to_s"
}

function urldecode {
    if ! command -v ruby >/dev/null 2>&1; then
        return
    fi

    local uri="$1"
    ruby -rcgi -e "puts CGI.unescape('$uri')"
}
