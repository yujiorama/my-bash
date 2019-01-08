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
PATH=/bin:/usr/bin:/usr/bin/core_perl:/usr/bin/vendor_perl:/usr/local/bin:/usr/libexec:/mingw64/bin:/mingw64/libexec
rm -f ${HOME}/.bash_path_suffix ${HOME}/.bash_path_prefix

cygpath --unix "${HOME}/bin" >> ${HOME}/.bash_path_prefix
cygpath --unix "${HOME}/.git-secrets" >> ${HOME}/.bash_path_prefix

echo "/c/WINDOWS" >> ${HOME}/.bash_path_suffix
echo "/c/WINDOWS/system32" >> ${HOME}/.bash_path_suffix
echo "/c/WINDOWS/System32/Wbem" >> ${HOME}/.bash_path_suffix
echo "/c/WINDOWS/System32/WindowsPowerShell/v1.0" >> ${HOME}/.bash_path_suffix

if [[ -d "/c/ProgramData/chocolatey/bin" ]]; then
    echo "/c/ProgramData/chocolatey/bin" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "${HOME}/scoop/shims" ]]; then
    echo "${HOME}/scoop/shims" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "/c/HashiCorp/Vagrant" ]]; then
    VAGRANT_ROOT="/c/HashiCorp/Vagrant"
    cygpath --unix "${VAGRANT_ROOT}/bin" >> ${HOME}/.bash_path_suffix
    cygpath --unix "${VAGRANT_ROOT}/embedded/bin" >> ${HOME}/.bash_path_suffix
    cygpath --unix "${VAGRANT_ROOT}/embedded/mingw/bin" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "/c/Program Files/Oracle/VirtualBox" ]]; then
    cygpath --unix "/c/Program Files/Oracle/VirtualBox" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "/c/Program Files/MySQL/MySQL Workbench 8.0 CE" ]]; then
    export MYSQLINSTALL
    MYSQLINSTALL="/c/Program Files/MySQL/MySQL Workbench 8.0 CE"
    cygpath --unix "${MYSQLINSTALL}" >> ${HOME}/.bash_path_suffix
fi
if [[ -d "/c/Program Files/TortoiseSVN" ]]; then
    export TORTOISESVNINSTALL
    TORTOISESVNINSTALL="/c/Program Files/TortoiseSVN"
    cygpath --unix "${TORTOISESVNINSTALL}/bin" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "/c/Program Files/Git LFS" ]]; then
    echo "/c/Program Files/Git LFS" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows" ]]; then
    cygpath --unix "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "/c/Program Files/heroku/bin" ]]; then
    echo "/c/Program Files/heroku/bin" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "/c/Program Files/Microsoft VS Code/bin" ]]; then
    echo "/c/Program Files/Microsoft VS Code/bin" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "/c/Program Files/nodejs" ]]; then
    if [[ -d "${APPDATA}/npm" ]]; then
        cygpath --unix "${APPDATA}/npm" >> ${HOME}/.bash_path_suffix
    fi
    if [[ -d "/c/Program Files/nodejs/node_modules/.bin" ]]; then
        echo "/c/Program Files/nodejs/node_modules/.bin" >> ${HOME}/.bash_path_suffix
    fi
    echo "/c/Program Files/nodejs" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "${ConEmuBaseDir}" ]]; then
    cygpath --unix "$(dirname "${ConEmuBaseDir}")" >> ${HOME}/.bash_path_suffix
    cygpath --unix "${ConEmuBaseDir}" >> ${HOME}/.bash_path_suffix
    cygpath --unix "${ConEmuBaseDir}/Scripts" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "$LOCALAPPDATA/Pandoc" ]]; then
    cygpath --unix "$LOCALAPPDATA/Pandoc" >> ${HOME}/.bash_path_suffix
fi

if [[ -d "/c/Program Files/Docker/Docker/Resources/bin" ]]; then
    echo "/c/Program Files/Docker/Docker/Resources/bin" >> ${HOME}/.bash_path_suffix
fi

if [[ -e "${HOME}/.bash_path_prefix" ]]; then
    PATH=$(cat ${HOME}/.bash_path_prefix | tr '\n' ':' | sed -e 's/::/:/g'):${PATH}
fi

if [[ -e "${HOME}/.bash_path_suffix" ]]; then
    PATH=${PATH}:$(cat ${HOME}/.bash_path_suffix | tr '\n' ':' | sed -e 's/::/:/g')
fi

[ -e ${HOME}/.bashrc ] && source ${HOME}/.bashrc
