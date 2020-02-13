# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if ! command -v curl >/dev/null 2>&1; then
	return
fi

eval "$(curl -fsSL "https://raw.githubusercontent.com/GArik/bash-completion/master/completions/curl")"
