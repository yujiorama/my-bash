# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

# shellcheck source=/dev/null
[[ -e "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"

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
    HOME=$(/bin/cygpath --unix "${USERPROFILE}")
fi
export PAGER
PAGER='less -r -F'
export MSYS
MSYS=winsymlinks:nativestrict

umask 0022

# shellcheck source=/dev/null
[[ -e /bin/dircolors ]] && source <(/bin/dircolors --sh)

export PATH
PATH=/bin:/usr/bin:/usr/bin/core_perl:/usr/bin/vendor_perl:/usr/local/bin:/usr/libexec:/mingw64/bin:/mingw64/libexec
/bin/rm -f "${HOME}/.bash_path_suffix" "${HOME}/.bash_path_prefix"

{
    /bin/cygpath --unix "${HOME}/bin";
    /bin/cygpath --unix "${HOME}/.git-secrets";
} >> "${HOME}/.bash_path_prefix"

{
    echo "/c/WINDOWS";
    echo "/c/WINDOWS/system32";
    echo "/c/WINDOWS/System32/Wbem";
    echo "/c/WINDOWS/System32/WindowsPowerShell/v1.0";
} >> "${HOME}/.bash_path_suffix"

if [[ -d "${HOME}/scoop/shims" ]]; then
    echo "${HOME}/scoop/shims" >> "${HOME}/.bash_path_prefix"
fi

if [[ -d "/c/ProgramData/chocolatey/bin" ]]; then
    echo "/c/ProgramData/chocolatey/bin" >> "${HOME}/.bash_path_prefix"
fi

if [[ -d "${ConEmuBaseDir}" ]]; then
    {
        /bin/cygpath --unix "$(dirname "${ConEmuBaseDir}")"
        /bin/cygpath --unix "${ConEmuBaseDir}"
        /bin/cygpath --unix "${ConEmuBaseDir}/Scripts"
    }  >> "${HOME}/.bash_path_suffix"
fi

if [[ -e "${HOME}/.bash_path_prefix" ]]; then
    PATH=$(/bin/cat "${HOME}/.bash_path_prefix" | /bin/tr '\n' ':' | /bin/sed -e 's/::/:/g'):${PATH}
fi

if [[ -e "${HOME}/.bash_path_suffix" ]]; then
    PATH=${PATH}:$(/bin/cat "${HOME}/.bash_path_suffix" | /bin/tr '\n' ':' | /bin/sed -e 's/::/:/g')
fi

[[ -x c:/WINDOWS/system32/chcp.com ]] && c:/WINDOWS/system32/chcp.com 65001

__here()
{
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -wa "$PWD"
    else
        echo "$PWD"
    fi
}


__download_new_file()
{
    local src dst ctime
    src=$1
    dst=$2
    ctime=$(LANG=C date --utc --date="10 years ago" +"%a, %d %b %Y %H:%M:%S GMT")
    if [[ -e "${dst}" ]]; then
        ctime=$(LANG=C date --utc --date=@"$(stat --format='%Y' ${dst})" +"%a, %d %b %Y %H:%M:%S GMT")
    fi
    if command -v curl >/dev/null 2>&1; then
        local modified
        modified=$(
            curl -fsSL -I -H "If-Modified-Since: ${ctime}" -o /dev/null -w %\{http_code\} "${src}"
        )
        if [[ "200" = "${modified}" ]]; then
            curl -fsSL --output "${dst}" "${src}" >/dev/null 2>&1
        fi
    elif command -v http >/dev/null 2>&1; then
        http --follow --continue --download --output "${dst}" "${src}" >/dev/null 2>&1
    fi
    ls -l "${dst}"
}
alias download_new_file='__download_new_file '


__online()
{
    local domain port
    domain=${1:-www.google.com}
    port=${2:-80}
    if ! command -v tiny-nc >/dev/null 2>&1; then
        return 1
    fi
    tiny-nc -timeout 1s "${domain}" "${port}"
    return $?
}
alias online='__online '

sourcedir="$(dirname "${BASH_SOURCE[0]}")"

[[ -e "${sourcedir}/go.sh" ]] && source "${sourcedir}/go.sh"

cachedir="${HOME}/.cache"
mkdir -p "${cachedir}"
cacheid=$(/bin/find "${sourcedir}" -type f -name \*.env \
        | /bin/xargs -r /bin/cat \
        | /bin/md5sum --binary - \
        | /bin/cut -d ' ' -f 1)

/bin/find "${cachedir}" -type f -not -name \*"-${cacheid}" | /bin/xargs -r /bin/rm -f

for f in $(/bin/find "${sourcedir}" -type f | /bin/grep -v .bash_profile | /bin/sort); do
    stdout_log=$(/bin/mktemp)
    stderr_log=$(/bin/mktemp)
    /bin/echo -n "${f}: "
    starttime=$SECONDS
    cached_=""
    if [[ "env" = "${f##*.}" ]]; then
        cachefile_="${cachedir}/$(basename ${f})-${cacheid}"
        if [[ -e "${cachefile_}" ]]; then
            cached_=" (cached)"
            source "${cachefile_}"
        else
            envbefore=$(mktemp)
            envafter=$(mktemp)
            printenv | /bin/sort > "${envbefore}"
            source "${f}" 2>"${stderr_log}" >"${stdout_log}"
            printenv | /bin/sort > "${envafter}"
            /bin/diff --text --suppress-common-lines "${envbefore}" "${envafter}" \
                | /bin/grep -E '^>' \
                | /bin/sed -r \
                      -e "s|^> ([^=]+)=(.*)|export \1=\'\2\'|" \
                > "${cachefile_}"
            /bin/rm -f "${envbefore}" "${envafter}"
        fi
    else
        source "${f}" 2>"${stderr_log}" >"${stdout_log}"
    fi
    laptime=$(( SECONDS - starttime ))
    /bin/echo "${laptime} sec${cached_}"
    if [[ -s ${stdout_log} ]]; then
        /bin/echo "=== stdout"; /bin/cat "${stdout_log}"; /bin/echo
    fi
    if [[ -s ${stderr_log} ]]; then
        /bin/echo "=== stderr"; /bin/cat "${stderr_log}"; /bin/echo
    fi
    /bin/rm -f "${stdout_log}" "${stderr_log}"
done

export PS1
if declare -f __here >/dev/null; then
    PS1='\[\e[35m\]\u@\h `__here`\n'
else
    PS1='\[\e[35m\]\u@\h\n'
fi
if declare -f __git_ps1 >/dev/null; then
    PS1=$PS1'\[\e[33m\]\w\[\e[36m\]`__git_ps1 " (%s)"`\[\e[0m\]\n'
fi
PS1=$PS1'$ '
# PS1='\[\e[35m\]\u@\h `__here`\n\[\e[33m\]\w\[\e[36m\]`__git_ps1 " (%s)"`\[\e[0m\]\n`kube_ps1`\n$'
echo "Startup Time: $SECONDS sec"
