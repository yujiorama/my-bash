#!/bin/bash
if [[ -e "${HOME}/bin/password-store/share/bash-completion/completions/pass" ]]; then
	# shellcheck source=/dev/null
    source "${HOME}/bin/password-store/share/bash-completion/completions/pass"
fi
