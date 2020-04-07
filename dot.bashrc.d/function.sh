#!/bin/bash
function ip {
    local subcommand=$1
    case ${subcommand} in
        a)
            ipconfig | grep IPv4 | cut -d ':' -f 2 | sed -e 's/^ //'
        ;;
    esac
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
