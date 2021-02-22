# shellcheck shell=bash

if [[ "${OS}" = "Linux" ]]; then
    return
fi

if ! command -v scoop >/dev/null 2>&1; then
    return
fi

function __jdk-function-source {
    local scoop_app version
    scoop_app="$1"
    version="$2"

    local java_home
    java_home=$(cygpath -ma "${HOME}/scoop/apps/${scoop_app}/current")
    if [[ ! -d "${java_home}" ]]; then
        if scoop install "${scoop_app}" | grep "Couldn't find manifest" >/dev/null 2>&1; then
            return
        fi
    fi

    local suffix function_source
    suffix="$version"
    function_source="${HOME}/.jdk/java${version}"

    mkdir -p "${HOME}/.jdk"
    echo ":" > "${HOME}/.jdk/empty"
    if [[ -e "${java_home}/bin/java" ]]; then
        cp /dev/null "${function_source}"
        local executable
        /usr/bin/find -L "${java_home}/bin" -type f -name \*.exe | while read -r executable; do
            printf "function %s() {\nJAVA_HOME=\"%s\" \"%s\" \$*\n}\n" \
                "$(basename "${executable}" .exe)${suffix}" \
                "${java_home}" \
                "${executable}"
        done | tee "${function_source}"
    fi
    echo "export JAVA${version}_HOME=\"${java_home}\""
}

function __jdk {

    local scoop_app
    for scoop_app in ${!SCOOP_APP_JAVA*}; do
        local version
        version="$(echo "${scoop_app}" | cut -d '_' -f 4)"
        __jdk-function-source "${!scoop_app}" "${version}"
    done
}

function __java_home {
    local latest
    # shellcheck disable=SC2086
    latest="$(echo ${!SCOOP_APP_JAVA*} | tr ' ' '\n' | sort -t '_' -k 4 -n -r | head -n 1)"
    if [[ -n "${latest}" ]]; then
        local version home
        version="$(echo "${latest}" | cut -d '_' -f 4)"
        home="$(printf "JAVA%s_HOME" "${version}")"
        export JAVA_HOME="${!home}"
    fi
}

function __lombok {
    local url destination
    url="https://projectlombok.org/downloads/lombok.jar"
    destination="${HOME}/.lombok/$(basename "${url}")"

    mkdir -p "$(dirname "${destination}")"
    download_new_file "${url}" "${destination}"
}

(__jdk; echo '__java_home') > "${MY_BASH_ENV}/jdk"
ls -l "${MY_BASH_ENV}/jdk"

__lombok
