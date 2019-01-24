PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'jdk' | tr '\n' ':')

export JAVA_OPTS
JAVA_OPTS="-Dfile.encoding=UTF-8"
export JDK8_HOME
JDK8_HOME=$(cygpath --mixed "$(scoop prefix ojdkbuild8)")
export JDK12_HOME
JDK12_HOME=$(cygpath --mixed "$(scoop prefix openjdk12)")
export JAVA_HOME
JAVA_HOME="${JDK12_HOME}"

java_home() {
    echo ${JAVA_HOME}
}

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

download_new_file__()
{
    local src=$1
    local dst=$2
    if [[ -e ${dst} ]]; then
        ctime_=$(
            LANG=C date --utc --date=@"$(stat --format='%Y' ${dst})" +"%a, %d %b %Y %H:%M:%S GMT"
        )
    else
        ctime_=$(
            LANG=C date --utc --date="10 years ago" +"%a, %d %b %Y %H:%M:%S GMT"
        )
    fi
    if which curl >/dev/null 2>&1; then
        modified_=$(
            curl -fsSL -I -H "If-Modified-Since: ${ctime_}" -o /dev/null -w %{http_code} ${src}
        )
        if [[ "200" = "${modified_}" ]]; then
            curl -fsSL --output ${dst} ${src} >/dev/null 2>&1
        fi
    elif which http >/dev/null 2>&1; then
        http --follow --continue --download --output ${dst} ${src} >/dev/null 2>&1
    fi
    ls -l ${dst}
}

mkdir -p ${HOME}/.lombok
download_new_file__ "https://projectlombok.org/downloads/lombok.jar" "${HOME}/.lombok/lombok.jar"

mkdir -p ${HOME}/.plantuml
download_new_file__ "http://sourceforge.net/projects/plantuml/files/plantuml.jar/download" "${HOME}/.plantuml/plantuml.jar"

mkdir -p ${HOME}/.pleiades
download_new_file__ "http://ftp.jaist.ac.jp/pub/mergedoc/pleiades/build/stable/pleiades.zip" "${HOME}/.pleiades/pleiades.zip"
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
