# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

[[ -e ${HOME}/.bashrc ]] && source ${HOME}/.bashrc

for d in work Downloads .aws .m2 wsl; do
    if ! /bin/mountpoint -q ${HOME}/${d}; then
        /bin/mkdir -p ${HOME}/${d}
        /usr/bin/sudo /bin/mount --bind /mnt/c/Users/y_okazawa/${d} ${HOME}/${d}
    fi
done

if ! /bin/mountpoint -q /c; then
    /usr/bin/sudo /bin/mkdir -p /c
    /usr/bin/sudo /bin/mount --bind /mnt/c /c
fi

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

error_log=$(/bin/mktemp)
for f in $(/usr/bin/find ${HOME}/wsl/.bashrc.d -type f | /bin/grep -v .bash_profile | /usr/bin/sort); do
    starttime=$SECONDS
    source ${f} 2>${error_log}
    if [[ -s ${error_log} ]]; then
        echo "${f}: $(/bin//bin/cat ${error_log})"
    fi
    laptime=$(( SECONDS - starttime ))
    echo "${f}: $laptime sec"
done
/bin/rm -f ${error_log}

if [[ -d ${HOME}/.sdkman ]]; then
    export SDKMAN_DIR="${HOME}/.sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

__here()
{
    case ${OS:-Linux} in
        Windows*) cygpath -wa "${PWD}" ;;
        *)        echo ${PWD} ;;
    esac
}
alias here='__here'

export PS1
# PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
PS1='\033[01;32m\]\u@\h `here`\n\[\033[33m\]\w\[\033[36m\]`__git_ps1 " (%s)"`\[\033[0m\]\n`kube_ps1`\n$ '

echo "Startup Time: $SECONDS sec"

