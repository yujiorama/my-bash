PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'jdk' | tr '\n' ':')

export JAVA_OPTS
JAVA_OPTS="-Dfile.encoding=UTF-8"
if scoop list | grep -w "adopt8-openj9"; then
    export JDK8_HOME
    JDK8_HOME=$(cygpath --mixed "$(scoop prefix adopt8-openj9)")
fi
if scoop list | grep -w openjdk11; then
    export JDK11_HOME
    JDK11_HOME=$(cygpath --mixed "$(scoop prefix openjdk11)")
fi
export JDK10_HOME=$(cygpath --mixed /c/work/happinet/jdk-10.0.2+13)
if scoop list | grep -w openjdk12; then
    export JDK12_HOME
    JDK12_HOME=$(cygpath --mixed "$(scoop prefix openjdk12)")
fi
export JAVA_HOME
JAVA_HOME="${JDK12_HOME}"

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
__jdk_function "${JDK12_HOME}" "12" ""

mkdir -p ${HOME}/.lombok
download_new_file "https://projectlombok.org/downloads/lombok.jar" "${HOME}/.lombok/lombok.jar" &

mkdir -p ${HOME}/.plantuml
download_new_file "http://sourceforge.net/projects/plantuml/files/plantuml.jar/download" "${HOME}/.plantuml/plantuml.jar" &

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
