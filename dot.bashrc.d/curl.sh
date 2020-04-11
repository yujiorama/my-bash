#!/bin/bash
if ! command -v curl >/dev/null 2>&1; then
	return
fi

completion="${HOME}/.completion/curl"
url="https://raw.githubusercontent.com/GArik/bash-completion/master/completions/curl"

download_new_file "${url}" "${completion}"

unset completion url
