# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -e "${HOME}/bin/password-store/share/bash-completion/completion/pass" ]]; then
    source <( /bin/cat ${HOME}/bin/password-store/share/bash-completion/completion/pass )
fi
