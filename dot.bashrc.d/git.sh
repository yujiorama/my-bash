#!/bin/bash
export PATH
PATH="${PATH}:/mingw64/libexec/git-core"

if [[ -e ${HOME}/git-prompt.sh ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/git-prompt.sh"
fi
if [[ -e /mingw64/share/git/completion/git-prompt.sh ]]; then
    # shellcheck source=/dev/null
    source "/mingw64/share/git/completion/git-prompt.sh"
fi

mkdir -p "${HOME}/.git-templates" "${HOME}/man/man1"
download_new_file "https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets" "/mingw64/bin/git-secrets"
download_new_file "https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets.1" "${HOME}/man/man1/git-secrets.1"

echo run git secrets --install -f "${HOME}/.git-templates"
echo run git config --global init.templateDir "${HOME}/.git-templates/git-secrets"
echo run git secrets --register-aws --global

export MANPATH
MANPATH=${HOME}/man/man1:${MANPATH}
