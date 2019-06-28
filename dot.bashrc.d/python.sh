# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if online pypi.org 443; then
    for pkg in see awscli httpie; do
        ${PYTHON} -m pip install --user --progress-bar off --no-color --timeout 3 ${pkg} >/dev/null 2>&1 &
    done
    wait
fi

if which aws_completer >/dev/null 2>&1; then
    complete -C aws_completer aws
fi
