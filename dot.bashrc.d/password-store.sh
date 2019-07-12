# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -e "${HOME}/bin/password-store/share/bash-completion/completions/pass" ]]; then
	# shellcheck source=/dev/null
    source "${HOME}/bin/password-store/share/bash-completion/completions/pass"
fi
