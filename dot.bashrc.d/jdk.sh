PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'jdk' | tr '\n' ':')

export JAVA_OPTS
JAVA_OPTS="-Dfile.encoding=UTF-8"
export JDK8_HOME
if scoop list | grep -w ojdkbuild8; then
    JDK8_HOME=$(cygpath --mixed "$(scoop prefix ojdkbuild8)")
fi
export JDK12_HOME
if scoop list | grep -w openjdk12; then
    JDK12_HOME=$(cygpath --mixed "$(scoop prefix openjdk12)")
fi
export JAVA_HOME
JAVA_HOME="${JDK12_HOME}"

if [[ -z "${JAVA_HOME}" ]]; then
    return
fi

if [[ ! -e "${HOME}/.bashrc.d/jdk.function" ]]; then
    touch "${HOME}/.bashrc.d/jdk.function"
    for e in $(find ${JDK8_HOME}/bin -type f -name \*.exe); do
        e_name=$(basename ${e} .exe)
        printf "function %s8() {\nJAVA_HOME=\"\${JDK8_HOME}\" \"%s\" \$*\n}\n" ${e_name} ${e}
    done >> "${HOME}/.bashrc.d/jdk.function"

    for e in $(find ${JDK12_HOME}/bin -type f -name \*.exe); do
        e_name=$(basename ${e} .exe)
        printf "function %s() {\nJAVA_HOME=\"\${JDK12_HOME}\" \"%s\" \$*\n}\n" ${e_name} ${e}
    done >> "${HOME}/.bashrc.d/jdk.function"
fi
source "${HOME}/.bashrc.d/jdk.function"

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
