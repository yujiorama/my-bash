#!/bin/bash

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
    printf "export JAVA%s_HOME=\"%s\"\n" \
        "${version}" \
        "${java_home}"
}

function __jdk {
    local scoop_app

    for scoop_app in ${!SCOOP_APP_JAVA*}; do
        local version
        version="$(echo "${scoop_app}" | cut -d '_' -f 4)"
        __jdk-function-source "${!scoop_app}" "${version}"
    done

    local latest
    # shellcheck disable=SC2086
    latest="$(echo ${!SCOOP_APP_JAVA*} | tr ' ' '\n' | sort -t '_' -k 4 -n -r | head -n 1)"
    if [[ -n "${latest}" ]]; then
        local version home
        version="$(echo "${latest}" | cut -d '_' -f 4)"
        home="$(printf "JAVA%s_HOME" "${version}")"
        echo "export JAVA_HOME=\"${!home}\""
    fi
}

function __lombok {
    local url destination
    url="https://projectlombok.org/downloads/lombok.jar"
    destination="${HOME}/.lombok/$(basename "${url}")"

    mkdir -p "$(dirname "${destination}")"
    download_new_file "${url}" "${destination}"
}

function __pleiades {
    local url destination
    url="http://ftp.jaist.ac.jp/pub/mergedoc/pleiades/build/stable/pleiades.zip"
    destination="${HOME}/.pleiades/$(basename "${url}")"

    mkdir -p "$(dirname "${destination}")"
    download_new_file "${url}" "${destination}"

    if [[ -e "${destination}" ]]; then
        local workdir
        workdir=$(mktemp --directory)
        unzip -q -d "${workdir}" "${destination}"
        if [[ -e "${workdir}/plugins/jp.sourceforge.mergedoc.pleiades/pleiades.jar" ]]; then
            local src dst
            src="${workdir}/plugins/jp.sourceforge.mergedoc.pleiades/pleiades.jar"
            dst="$(dirname "${destination}")/pleiades.jar"
            if [[ "${src}" -nt "${dst}" ]]; then
                cp "${src}" "${dst}"
            fi
            ls -l "${dst}"
        fi
        rm -rf "${workdir}"
    fi
}

eval "$(__jdk)"

__lombok &
__pleiades &

wait
