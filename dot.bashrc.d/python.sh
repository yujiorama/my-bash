# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if ! command -v "${PYTHON}" >/dev/null 2>&1; then
	return
fi

if command -v aws_completer >/dev/null 2>&1; then
    complete -C aws_completer aws
fi

if another_console_exists; then
    return
fi

for pkg in see awscli httpie git-filter-repo; do
    ${PYTHON} -m pip install --user --progress-bar off --no-color --timeout 3 ${pkg} >/dev/null 2>&1 &
done
wait

