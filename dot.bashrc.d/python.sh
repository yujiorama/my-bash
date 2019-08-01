# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

for pkg in see awscli httpie; do
    ${PYTHON} -m pip install --user --progress-bar off --no-color --timeout 3 ${pkg} >/dev/null 2>&1 &
done
wait

if command -v aws_completer >/dev/null 2>&1; then
    complete -C aws_completer aws
fi
