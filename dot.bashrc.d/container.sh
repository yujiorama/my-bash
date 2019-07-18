# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

pwgen() {
    if ! command -v docker >/dev/null 2>&1; then
        exit 1
    fi
    docker container run --rm sofianinho/pwgen-alpine "$@"
}

gibo() {
    if ! command -v docker >/dev/null 2>&1; then
        exit 1
    fi
    docker container run --rm simonwhitaker/gibo "$@"
}
dot() {
    if ! command -v docker >/dev/null 2>&1; then
        exit 1
    fi
    local infile outfile
    infile=$1
    outfile=$2
    docker container run --rm --mount type=bind,src=/"$(pwd)",dst=//work fgrehm/graphviz dot -Tpng -o//work/"${outfile}" //work/"${infile}"
}
dockviz() {
    if ! command -v docker >/dev/null 2>&1; then
        exit 1
    fi
    docker container run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz "$@"
}
gcviewer() {
    local app_dir_path app_jar_name app_jar_path outdated download_url
    app_dir_path="${HOME}/.gcviewer"
    app_jar_name="${FUNCNAME[0]}.jar"
    app_jar_path=$(cygpath -w "${app_dir_path}/${app_jar_name}")
    if [[ ! -d "${app_dir_path}" ]]; then
        mkdir -p "${app_dir_path}"
    fi
    outdated=$(/usr/bin/find -L ${app_dir_path} -type f -name "${app_jar_name}" -mtime +14)
    if [[ ! -e "${app_jar_path}" ]] || [[ ! -z "${outdated}" ]]; then
        ## XXX
        download_url="http://central.maven.org/maven2/com/github/chewiebug/gcviewer/1.35/gcviewer-1.35.jar"
        curl --connect-timeout 3 --location --continue-at - --silent --output "${app_jar_path}" "${download_url}"
    fi
    "${JAVA_HOME}/bin/java" -jar "${app_jar_path}" "$@"
}
stream2es() {
    local app_dir_path app_jar_name app_jar_path outdated download_url
    app_dir_path="${HOME}/.stream2es"
    app_jar_name="${FUNCNAME[0]}.jar"
    app_jar_path=$(cygpath -w "${app_dir_path}/${app_jar_name}")
    if [[ ! -d "${app_dir_path}" ]]; then
        mkdir -p "${app_dir_path}"
    fi
    outdated=$(/usr/bin/find -L ${app_dir_path} -type f -name "${app_jar_name}" -mtime +14)
    if [[ ! -e "${app_jar_path}" ]] || [[ ! -z "${outdated}" ]]; then
        download_url="https://download.elasticsearch.org/stream2es/stream2es"
        curl --connect-timeout 3 --location --continue-at - --silent --output "${app_jar_path}" "${download_url}"
    fi
    "${JAVA_HOME}/bin/java" -jar "${app_jar_path}" "$@"
}
dbxcli() {
    local app_dir_path app_exe_path download_url
    app_dir_path="${HOME}/.dbxcli"
    app_exe_path="${app_dir_path}/dbxcli.exe"
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
    ${app_exe_path} "$@"
}
sslyze() {
    if ! command -v docker >/dev/null 2>&1; then
        exit 1
    fi
    docker container run -it --rm --network host nablac0d3/sslyze "$@"
}
