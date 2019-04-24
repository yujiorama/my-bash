# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'jdk|adopt' | tr '\n' ':')

export JAVA_OPTS
JAVA_OPTS="-Dfile.encoding=UTF-8"
if scoop list | grep -w adopt8-openj9; then
    export JDK8_HOME
    JDK8_HOME=$(cygpath --mixed "$(scoop prefix adopt8-openj9)")
fi
if scoop list | grep -w adopt11-openj9; then
    export JDK11_HOME
    JDK11_HOME=$(cygpath --mixed "$(scoop prefix adopt11-openj9)")
fi
if scoop list | grep -w openjdk10; then
    export JDK10_HOME
    JDK10_HOME=$(cygpath --mixed "$(scoop prefix openjdk10)")
fi
if scoop list | grep -w adopt12-openj9; then
    export JDK12_HOME
    JDK12_HOME=$(cygpath --mixed "$(scoop prefix adopt12-openj9)")
fi

if scoop list | grep -w openjdk13; then
    export JDK13_HOME
    JDK13_HOME=$(cygpath --mixed "$(scoop prefix openjdk13)")
fi
export JAVA_HOME
JAVA_HOME="${JDK13_HOME}"

if [[ -z "${JAVA_HOME}" ]]; then
    return
fi

__jdk_function()
{
    local java_home="$1"
    local version="$2"
    local suffix="$3"
    local function_source="${HOME}/.jdk/java${version}"
    mkdir -p ${HOME}/.jdk
    echo ":" > ${HOME}/.jdk/empty
    if [[ -e "${java_home}/bin/java" ]] &&
        [[ "${java_home}/bin/java" -nt "${function_source}" ]]; then
        cp /dev/null "${function_source}"
        for e in $(find ${java_home}/bin -type f -name \*.exe); do
            e_name=$(basename ${e} .exe)
            printf "function %s%s() {\nJAVA_HOME=\"\${java_home}\" \"%s\" \$*\n}\n" "${e_name}" "${suffix}" "${e}"
        done >> "${function_source}"
    fi
    source "${function_source}"
}

__jdk_function "${JDK8_HOME}" "8"  "8"
__jdk_function "${JDK10_HOME}" "10" "10"
__jdk_function "${JDK11_HOME}" "11" "11"
__jdk_function "${JDK12_HOME}" "12" "12"
__jdk_function "${JDK13_HOME}" "13" ""

mkdir -p ${HOME}/.lombok
download_new_file "https://projectlombok.org/downloads/lombok.jar" "${HOME}/.lombok/lombok.jar" &

(
mkdir -p ${HOME}/.pleiades
download_new_file "http://ftp.jaist.ac.jp/pub/mergedoc/pleiades/build/stable/pleiades.zip" "${HOME}/.pleiades/pleiades.zip"
if [[ -e "${HOME}/.pleiades/pleiades.zip" ]]; then
    workdir_=$(mktemp --directory --tmpdir=${HOME}/.pleiades)
    unzip -q -d ${workdir_} "${HOME}/.pleiades/pleiades.zip"
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
) &

wait
