# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

function ip {
    local subcommand=$1
    case ${subcommand} in
        a)
            ipconfig | grep IPv4 | cut -d ':' -f 2 | sed -e 's/^ //'
        ;;
    esac
}

function gcviewer {
    local app_dir_path app_jar_name app_jar_path outdated download_url
    app_dir_path="${HOME}/.gcviewer"
    app_jar_name="${FUNCNAME[0]}.jar"
    app_jar_path=$(cygpath -w "${app_dir_path}/${app_jar_name}")
    if [[ ! -d "${app_dir_path}" ]]; then
        mkdir -p "${app_dir_path}"
    fi
    outdated=$(/usr/bin/find -L ${app_dir_path} -type f -name "${app_jar_name}" -mtime +14)
    if [[ ! -e "${app_jar_path}" ]] || [[ -n "${outdated}" ]]; then
        ## XXX
        download_url="http://central.maven.org/maven2/com/github/chewiebug/gcviewer/1.35/gcviewer-1.35.jar"
        curl --connect-timeout 3 --location --continue-at - --silent --output "${app_jar_path}" "${download_url}"
    fi
    "${JAVA_HOME}/bin/java" -jar "${app_jar_path}" "$@"
}

function stream2es {
    local app_dir_path app_jar_name app_jar_path outdated download_url
    app_dir_path="${HOME}/.stream2es"
    app_jar_name="${FUNCNAME[0]}.jar"
    app_jar_path=$(cygpath -w "${app_dir_path}/${app_jar_name}")
    if [[ ! -d "${app_dir_path}" ]]; then
        mkdir -p "${app_dir_path}"
    fi
    outdated=$(/usr/bin/find -L ${app_dir_path} -type f -name "${app_jar_name}" -mtime +14)
    if [[ ! -e "${app_jar_path}" ]] || [[ -n "${outdated}" ]]; then
        download_url="https://download.elasticsearch.org/stream2es/stream2es"
        curl --connect-timeout 3 --location --continue-at - --silent --output "${app_jar_path}" "${download_url}"
    fi
    "${JAVA_HOME}/bin/java" -jar "${app_jar_path}" "$@"
}

function dbxcli {
    local app_dir_path app_exe_path download_url
    app_dir_path="${HOME}/.dbxcli"
    app_exe_path="${app_dir_path}/dbxcli.exe"
    if [[ ! -x "${app_exe_path}" ]]; then
      mkdir -p "${app_dir_path}"
      curl --silent --header 'Accept: application/json' https://api.github.com/repos/dropbox/dbxcli/releases |
        jq -r '
          max_by(.name) |
          .name as $version |
          .assets[] |
          select(.name | contains("windows")) |
          {version:$version, url:.browser_download_url}' > "${app_dir_path}/.new"
      if [[ ! -e ${app_dir_path}/.current ]]; then
          cp "${app_dir_path}/.new" "${app_dir_path}/.current"
          download_url=$(cat ${app_dir_path}/.new | jq -r .url)
          curl --silent --location --output "${app_exe_path}" "${download_url}"
      else
          local current_version new_version
          current_version=$(cat ${app_dir_path}/.current | jq -r .version)
          new_version=$(cat ${app_dir_path}/.new | jq -r .version)
          if [[ ${current_version} != ${new_version} ]]; then
              download_url=$(cat ${app_dir_path}/.new | jq -r .url)
              curl --silent --location --output "${app_exe_path}" "${download_url}"
          fi
      fi
    fi
    ${app_exe_path} "$@"
}
