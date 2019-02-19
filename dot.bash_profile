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

if [[ -d "${HOME}/scoop/shims" ]]; then
    echo "${HOME}/scoop/shims" >> ${HOME}/.bash_path_prefix
fi

if [[ -d "/c/ProgramData/chocolatey/bin" ]]; then
    echo "/c/ProgramData/chocolatey/bin" >> ${HOME}/.bash_path_prefix
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
