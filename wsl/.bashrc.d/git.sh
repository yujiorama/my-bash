# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

unset GIT_LFS_PATH

export GIT_SSH
GIT_SSH=ssh

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto
export GIT_PS1_DESCRIBE_STYLE=branch
export GIT_PS1_SHOWCOLORHINTS=true

if [[ -e ${HOME}/git-prompt.sh ]]; then
	# shellcheck source=/dev/null
    source "${HOME}/git-prompt.sh"
elif [[ -e /mingw64/share/git/completion/git-prompt.sh ]]; then
	# shellcheck source=/dev/null
    source "/mingw64/share/git/completion/git-prompt.sh"
elif [[ -e /etc/bash_completion.d ]] && [[ -e /etc/bash_completion.d/git-prompt ]]; then
	# shellcheck source=/dev/null
    source "/etc/bash_completion.d/git-prompt"
fi

if [[ -n "${WSLENV}" ]]; then
    return
fi

mkdir -p "${HOME}/.git-secrets" "${HOME}/.git-templates" "${HOME}/man/man1"
download_new_file "https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets" "${HOME}/.git-secrets/git-secrets"
chmod 755 "${HOME}/.git-secrets/git-secrets"
download_new_file "https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets.1" "${HOME}/man/man1/git-secrets.1"

echo run git secrets --install -f "${HOME}/.git-templates"
echo run git config --global init.templateDir "${HOME}/.git-templates/git-secrets"
echo run git secrets --register-aws --global

export PATH
PATH="${HOME}/.git-secrets":${PATH}

export MANPATH
MANPATH=${HOME}/man/man1:${MANPATH}
