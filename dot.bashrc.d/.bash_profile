# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

[ -e ${HOME}/.bashrc ] && source ${HOME}/.bashrc

if [[ -z "${TERM}" ]]; then
    export TERM
    TERM=cygwin
fi
export LANG
LANG=ja_JP.UTF-8
export LC_CTYPE
LC_CTYPE=${LANG}
if [[ -z "${HOME}" ]]; then
    export HOME
    HOME=/c/Users/y.okazawa
fi
export PAGER
PAGER='less -r -F'

export PATH
PATH=/bin:/usr/bin:/usr/bin/core_perl:/usr/bin/vendor_perl:/usr/local/bin:/usr/libexec:/mingw64/bin:/mingw64/libexec
/bin/rm -f ${HOME}/.bash_path_suffix ${HOME}/.bash_path_prefix

/bin/cygpath --unix "${HOME}/bin" >> ${HOME}/.bash_path_prefix
/bin/cygpath --unix "${HOME}/.git-secrets" >> ${HOME}/.bash_path_prefix

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

if [[ -d "${ConEmuBaseDir}" ]]; then
    /bin/cygpath --unix "$(dirname "${ConEmuBaseDir}")" >> ${HOME}/.bash_path_suffix
    /bin/cygpath --unix "${ConEmuBaseDir}" >> ${HOME}/.bash_path_suffix
    /bin/cygpath --unix "${ConEmuBaseDir}/Scripts" >> ${HOME}/.bash_path_suffix
fi

if [[ -e "${HOME}/.bash_path_prefix" ]]; then
    PATH=$(/bin/cat ${HOME}/.bash_path_prefix | /bin/tr '\n' ':' | /bin/sed -e 's/::/:/g'):${PATH}
fi

if [[ -e "${HOME}/.bash_path_suffix" ]]; then
    PATH=${PATH}:$(/bin/cat ${HOME}/.bash_path_suffix | /bin/tr '\n' ':' | /bin/sed -e 's/::/:/g')
fi

c:/WINDOWS/system32/chcp.com 65001

envdir="${HOME}/.bashrc.d"
error_log=$(/bin/mktemp)
for f in $(/bin/find ${envdir} -type f | /bin/grep -v .bash_profile | /bin/sort); do
    starttime=$SECONDS
    source ${f} 2>${error_log}
    if [[ -s ${error_log} ]]; then
        echo "${f}: $(/bin//bin/cat ${error_log})"
    fi
    laptime=$(( SECONDS - starttime ))
    echo "${f}: $laptime sec"
done
/bin/rm -f ${error_log}

export PS1
# PS1='\033[35m\]\u@\h `here`\n\[\033[33m\]\w\[\033[36m\]`__git_ps1 " (%s)"`\[\033[0m\]\n$ '
PS1='\033[35m\]\u@\h `here`\n\[\033[33m\]\w\[\033[36m\]`__git_ps1 " (%s)"`\[\033[0m\]\n`kube_ps1`\n$ '

echo "Startup Time: $SECONDS sec"
