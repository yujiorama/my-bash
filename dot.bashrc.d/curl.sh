#!/bin/bash
if ! command -v curl >/dev/null 2>&1; then
	return
fi

download_new_file "https://raw.githubusercontent.com/GArik/bash-completion/master/completions/curl" "${HOME}/bin/curl.completion"

if [[ -e "${HOME}/bin/curl.completion" ]]; then
    # shellcheck source=/dev/null
	source "${HOME}/bin/curl.completion"
fi
