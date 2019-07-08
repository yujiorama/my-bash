# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

[[ -e ${HOME}/.bashrc ]] && source ${HOME}/.bashrc

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
    HOME=$(/bin/cygpath --unix ${USERPROFILE})
fi
export PAGER
PAGER='less -r -F'

[[ -e /bin/dircolors ]] && source <(/bin/dircolors --sh)

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

[[ -x c:/WINDOWS/system32/chcp.com ]] && c:/WINDOWS/system32/chcp.com 65001

__here()
{
    if [[ 0 -eq "$(which cygpath >/dev/null 2>&1; echo $?)" ]]; then
        cygpath -wa "$PWD"
    else
        echo "$PWD"
    fi
}


__download_new_file()
{
    local src=$1
    local dst=$2
    local ctime=$(
        LANG=C date --utc --date="10 years ago" +"%a, %d %b %Y %H:%M:%S GMT"
    )
    if [[ -e ${dst} ]]; then
        ctime=$(
            LANG=C date --utc --date=@"$(stat --format='%Y' ${dst})" +"%a, %d %b %Y %H:%M:%S GMT"
        )
    else
        :
    fi
    if which curl >/dev/null 2>&1; then
        local modified=$(
            curl -fsSL -I -H "If-Modified-Since: ${ctime}" -o /dev/null -w %{http_code} ${src}
        )
        if [[ "200" = "${modified}" ]]; then
            curl -fsSL --output ${dst} ${src} >/dev/null 2>&1
        fi
    elif which http >/dev/null 2>&1; then
        http --follow --continue --download --output ${dst} ${src} >/dev/null 2>&1
    else
        :
    fi
    ls -l ${dst}
}
alias download_new_file='__download_new_file '


__online()
{
    local domain=$1
    local port=$2
    domain=${domain:-www.google.com}
    port=${port:-80}
    if ! which tiny-nc >/dev/null 2>&1; then
        return 1
    fi
    tiny-nc -timeout 1s "${domain}" "${port}"
    return $?
}
alias online='__online '

[[ -e "$(dirname $BASH_SOURCE)/go.sh" ]] && source <(/bin/cat "$(dirname $BASH_SOURCE)/go.sh")


cachedir="${HOME}/.cache"
envdir="${HOME}/.bashrc.d"

mkdir -p "${cachedir}"
echo '__TEST=1' > ${cachedir}/.test
/bin/find ${cachedir} -type f -mtime +5 -exec /bin/rm -f {} \;

for f in $(/bin/find "${envdir}" -type f | /bin/grep -v .bash_profile | /bin/sort); do
    stdout_log=$(/bin/mktemp)
    stderr_log=$(/bin/mktemp)
    echo -n "${f}: "
    starttime=$SECONDS
    cached_=""
    if [[ "env" = "${f##*.}" ]]; then
        cachefile_="${cachedir}/$(basename ${f})-$(/bin/md5sum --binary ${f} | cut -d ' ' -f 1)"
        if [[ -e "${cachefile_}" ]]; then
            cached_=" (cached)"
            source <( /bin/cat ${cachefile_} )
        else
            envbefore=$(mktemp)
            envafter=$(mktemp)
            printenv | sort > ${envbefore}
            source <( /bin/cat ${f} ) 2>${stderr_log} >${stdout_log}
            printenv | sort > ${envafter}
            diff --text --suppress-common-lines ${envbefore} ${envafter} \
                | grep -E '^>' \
                | sed -r \
                      -e "s|^> ([^=]+)=(.*)|export \1=\'\2\'|" \
                > "${cachefile_}"
            rm -f ${envbefore} ${envafter}
        fi
    else
        source <( /bin/cat "${f}" ) 2>${stderr_log} >${stdout_log}
    fi
    laptime=$(( SECONDS - starttime ))
    echo "${laptime} sec${cached_}"
    if [[ -s ${stdout_log} ]]; then
        echo "=== stdout"; /bin/cat ${stdout_log}; echo
    fi
    if [[ -s ${stderr_log} ]]; then
        echo "=== stderr"; /bin/cat ${stderr_log}; echo
    fi
    /bin/rm -f ${stdout_log} ${stderr_log}
done

export PS1
if declare -f __here >/dev/null; then
    PS1='\033[35m\]\u@\h `__here`\n'
else
    PS1='\033[35m\]\u@\h\n'
fi
if declare -f __git_ps1 >/dev/null; then
    PS1=$PS1'\[\033[33m\]\w\[\033[36m\]`__git_ps1 " (%s)"`\[\033[0m\]\n'
fi
if declare -f kube_ps1 >/dev/null; then
    PS1=$PS1'`kube_ps1`\n'
fi
PS1=$PS1'$ '
# PS1='\033[35m\]\u@\h `__here`\n\[\033[33m\]\w\[\033[36m\]`__git_ps1 " (%s)"`\[\033[0m\]\n`kube_ps1`\n$'
echo "Startup Time: $SECONDS sec"
