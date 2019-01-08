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
