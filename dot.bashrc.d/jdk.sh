# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

__jdk_install()
{
    local package version suffix java_home
    package="$1"
    version="$2"
    suffix="$3"

    if scoop install "${package}" | grep "Couldn't find manifest" >/dev/null 2>&1; then
        return
    fi

    java_home=$(cygpath --mixed "$(scoop prefix "${package}")")

    printf "export JDK%s_HOME=\"%s\"\n" "${version}" "${java_home}"
    __jdk_function "${java_home}" "${version}" "${suffix}"
}

__jdk_function()
{
    local java_home version suffix function_source
    java_home="$1"
    version="$2"
    suffix="$3"
    function_source="${HOME}/.jdk/java${version}"
    mkdir -p "${HOME}/.jdk"
    echo ":" > "${HOME}/.jdk/empty"
    if [[ -e "${java_home}/bin/java" ]]; then
        cp /dev/null "${function_source}"
        /usr/bin/find -L "${java_home}/bin" -type f -name \*.exe | while read -r e; do
            local e_name
            e_name=$(basename "${e}" .exe)
            printf "function %s%s() {\nJAVA_HOME=\"\${java_home}\" \"%s\" \$*\n}\n" "${e_name}" "${suffix}" "${e}"
        done | tee "${function_source}"
    fi
}

# shellcheck source=/dev/null
source <(__jdk_install "${JDK8}" "8"  "8")
# shellcheck source=/dev/null
source <(__jdk_install "${JDK9}" "9"  "9")
# shellcheck source=/dev/null
source <(__jdk_install "${JDK10}" "10" "10")
# shellcheck source=/dev/null
source <(__jdk_install "${JDK11}" "11" "11")
# shellcheck source=/dev/null
source <(__jdk_install "${JDK12}" "12" "12")
# shellcheck source=/dev/null
source <(__jdk_install "${JDK13}" "13" "13")
# shellcheck source=/dev/null
source <(__jdk_install "${JDK14}" "14" "")

export JAVA_HOME="${JDK14_HOME}"

mkdir -p "${HOME}/.lombok"
download_new_file "https://projectlombok.org/downloads/lombok.jar" "${HOME}/.lombok/lombok.jar" &

{
    mkdir -p "${HOME}/.pleiades"
    download_new_file "http://ftp.jaist.ac.jp/pub/mergedoc/pleiades/build/stable/pleiades.zip" "${HOME}/.pleiades/pleiades.zip"
    if [[ -e "${HOME}/.pleiades/pleiades.zip" ]]; then
        workdir_=$(mktemp --directory --tmpdir=${HOME}/.pleiades)
        unzip -q -d "${workdir_}" "${HOME}/.pleiades/pleiades.zip"
        if [[ -e "${workdir_}/plugins/jp.sourceforge.mergedoc.pleiades/pleiades.jar" ]]; then
            src_="${workdir_}/plugins/jp.sourceforge.mergedoc.pleiades/pleiades.jar"
            dst_="${HOME}/.pleiades/pleiades.jar"
            if [[ "${src_}" -nt "${dst_}" ]]; then
                cp "${src_}" "${dst_}"
            fi
            unset src_ dst_
        fi
        rm -rf "${workdir_}"
        unset workdir_
        ls -l "${HOME}/.pleiades/pleiades.jar"
    fi
} &

wait
