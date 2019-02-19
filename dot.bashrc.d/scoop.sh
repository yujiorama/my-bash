# ex: ts=4 sw=4 et filetype=sh

if online github.com 443; then
    scoop update >/dev/null 2>&1
fi
scoop status
