# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

# shellcheck source=/dev/null
[[ -s ${HOME}/.bashrc ]] && source "${HOME}/.bashrc"

umask 0022

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

export PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/local/games:/usr/sbin:/usr/bin:/sbin:/bin
PATH=${HOME}/bin:${HOME}/.local/bin:${PATH}
PATH=${PATH}:/mnt/c/Windows:/mnt/c/Windows/System32

sourcedir="$(dirname "${BASH_SOURCE[0]}")"

for f in $(/usr/bin/find -L "${sourcedir}" -type f | /bin/grep -v .bash_profile | /usr/bin/sort); do
    stdout_log=$(/bin/mktemp)
    stderr_log=$(/bin/mktemp)
    echo -n "${f}: "
    starttime=$SECONDS
    source "${f}" 2>"${stderr_log}" >"${stdout_log}"
    laptime=$(( SECONDS - starttime ))
    echo "${laptime} sec"
    if [[ -s ${stdout_log} ]]; then
        echo "=== stdout"; /bin/cat "${stdout_log}"; echo
    fi
    if [[ -s ${stderr_log} ]]; then
        echo "=== stderr"; /bin/cat "${stderr_log}"; echo
    fi
    /bin/rm -f "${stdout_log}" "${stderr_log}"
done

__here()
{
    case ${OS:-Linux} in
        Windows*) cygpath -wa "${PWD}" ;;
        *)        echo "${PWD}" ;;
    esac
}
alias here='__here'

export PS1
# PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
PS1='\[\e[01;32m\]\u@\h `here`\n\[\e[33m\]\w\[\e[36m\]`__git_ps1 " (%s)"`\[\e[0m\]\n$ '

echo "Startup Time: $SECONDS sec"
