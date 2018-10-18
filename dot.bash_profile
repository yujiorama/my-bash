export TERM
TERM=cygwin
export LANG
LANG=ja_JP.UTF-8
export LC_CTYPE
LC_CTYPE=${LANG}
export HISTSIZE
HISTSIZE=100000
export HISTCONTROL
HISTCONTROL=ignoredups
export HISTTIMEFORMAT
HISTTIMEFORMAT='%Y-%m-%d %T '
if [[ -z "${HOME}" ]]; then
    export HOME
    HOME=/c/Users/y.okazawa
fi
export PAGER
PAGER='less -r -F'

export PATH
PATH=/bin:/usr/bin:/usr/libexec:/mingw64/bin:/mingw64/libexec:/c/ProgramData/chocolatey/bin:${HOME}/scoop/shims:${PATH}
rm -f ${HOME}/.bash_path_suffix ${HOME}/.bash_path_prefix

vagrant=$(which vagrant 2> /dev/null)
if [[ -z "${vagrant}" ]]; then
    VAGRANT_ROOT="/c/HashiCorp/Vagrant"
    cygpath --unix "${VAGRANT_ROOT}/bin" >> ${HOME}/.bash_path_suffix
    cygpath --unix "${VAGRANT_ROOT}/embedded/bin" >> ${HOME}/.bash_path_suffix
    cygpath --unix "${VAGRANT_ROOT}/embedded/mingw/bin" >> ${HOME}/.bash_path_suffix
fi

vboxmanage=$(which VBoxManage 2> /dev/null)
if [[ -z "${vboxmanage}" ]]; then
    cygpath --unix "/c/Program Files/Oracle/VirtualBox" >> ${HOME}/.bash_path_prefix
fi

if [[ -d "/c/tools/ruby25" ]]; then
    PATH=${PATH/\/c\/tools\/ruby25\/bin}
    RUBY_ROOT=/c/tools/ruby25
    cygpath --unix "${RUBY_ROOT}/bin" >> ${HOME}/.bash_path_prefix
fi
PATH=${PATH/\/c\/tools\/ruby24\/bin}
PATH=${PATH/\/c\/tools\/ruby23\/bin}

PATH=${PATH/\/c\/strawberry\/c\/bin}
PATH=${PATH/\/c\/strawberry\/perl\/bin}
PATH=${PATH/\/c\/strawberry\/perl\/site\/bin}

if [[ -d "/c/Python36" ]]; then
    PATH=${PATH/\/c\/Python36}
    python3() {
        "/c/Python36/python" $*
    }
    cygpath --unix "/c/Python36" >> ${HOME}/.bash_path_prefix
    cygpath --unix "/c/Python36/Scripts" >> ${HOME}/.bash_path_prefix
    cygpath --unix "${HOME}/AppData/Roaming/Python/Python36/Scripts" >> ${HOME}/.bash_path_prefix
fi
if [[ -d "/c/Python27" ]]; then
    PATH=${PATH/\/c\/Python27}
    python2() {
        "/c/Python27/python" $*
    }
    cygpath --unix "/c/Python27" >> ${HOME}/.bash_path_prefix
    cygpath --unix "/c/Python27/Scripts" >> ${HOME}/.bash_path_prefix
fi
export PYTHONIOENCODING=utf-8
export PIPENV_VENV_IN_PROJECT=true

export GOROOT
GOROOT=/c/Tools/go
export GOPATH
GOPATH=${HOME}/.go
go=$(which go 2> /dev/null)
if [[ -z "${go}" ]]; then
    export GOBIN
    GOBIN=${GOPATH}/bin
    cygpath --unix "${GOBIN}" >> ${HOME}/.bash_path_prefix
fi

mysql=$(which mysql 2> /dev/null)
if [[ -z "${mysql}" ]]; then
    export MYSQLINSTALL
    MYSQLINSTALL="/c/Program Files/MySQL/MySQL Workbench 6.3 CE"
    cygpath --unix "${MYSQLINSTALL}" >> ${HOME}/.bash_path_prefix
fi
svn=$(which svn 2> /dev/null)
if [[ -z "${svn}" ]]; then
    export TORTOISESVNINSTALL
    TORTOISESVNINSTALL="/c/Program Files/TortoiseSVN"
    cygpath --unix "${TORTOISESVNINSTALL}/bin" >> ${HOME}/.bash_path_prefix
fi

NODIST_PREFIX="/c/Program Files (x86)/Nodist"
_NODIST_BIN_DIR="${NODIST_PREFIX}/bin"
if [[ -f "$_NODIST_BIN_DIR/nodist.sh" ]]; then
    source "$_NODIST_BIN_DIR/nodist.sh"
fi
if [[ -f "$_NODIST_BIN_DIR/nodist_bash_profile_content.sh" ]]; then
    source "$_NODIST_BIN_DIR/nodist_bash_profile_content.sh"
fi
echo "${NODIST_PREFIX}/bin/" >> ${HOME}/.bash_path_prefix
unset _NODIST_BIN_DIR

export JAVA_OPTS
JAVA_OPTS="-Dfile.encoding=UTF-8"
export JDK8_HOME
JDK8_HOME=$(cygpath --mixed "$(scoop prefix ojdkbuild8)")
export JAVA_HOME
JAVA_HOME=$(cygpath --mixed "$(scoop prefix openjdk11)")
cygpath --unix "$(cygpath --mixed "${JAVA_HOME}")/bin" >> ${HOME}/.bash_path_prefix

if [[ ! -e ${HOME}/cacert.pem ]]; then
    http --download --output ${HOME}/cacert.pem https://curl.haxx.se/ca/cacert.pem >/dev/null 2>&1
else
    if [[ $(stat --format=%Y ${HOME}/cacert.pem) -lt $(date --date='1 days ago' +"%s") ]]; then
        http --download --output ${HOME}/cacert.pem https://curl.haxx.se/ca/cacert.pem >/dev/null 2>&1
    fi
fi

export SSL_CERT_FILE
SSL_CERT_FILE=${HOME}/cacert.pem

cygpath --unix "${HOME}/bin" >> ${HOME}/.bash_path_prefix

if [[ -e "${HOME}/.bash_path_prefix" ]]; then
    PATH=$(cat ${HOME}/.bash_path_prefix | tr '\n' ':' | sed -e 's/::/:/g'):${PATH}
fi

if [[ -e "${HOME}/.bash_path_suffix" ]]; then
    PATH=${PATH}:$(cat ${HOME}/.bash_path_suffix | tr '\n' ':' | sed -e 's/::/:/g')
fi

export GIT_SSH
if which plink >/dev/null 2>&1; then
    GIT_SSH=plink
else
    GIT_SSH=ssh
fi

[ -e ${HOME}/.bashrc ] && source ${HOME}/.bashrc
