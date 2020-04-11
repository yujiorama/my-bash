#!/bin/bash

if [[ -e "${HOME}/bin/password-store/share/bash-completion/completions/pass" ]]; then
    cp "${HOME}/bin/password-store/share/bash-completion/completions/pass" "${HOME}/.completion/pass"
fi
