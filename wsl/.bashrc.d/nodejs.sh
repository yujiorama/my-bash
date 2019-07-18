# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if command -v npm >/dev/null 2>&1; then
    mkdir -p "${HOME}/.nodejs"
    npm set prefix "${HOME}/.nodejs"
    PATH=${HOME}/.nodejs/bin:${PATH}
fi
