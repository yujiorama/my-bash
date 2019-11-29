# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if another_console; then
    return
fi

if [[ ! -e "${HOME}/cacert.pem" ]] ||
    [[ $(stat --format=%Y "${HOME}/cacert.pem") -lt $(date --date='1 days ago' +"%s") ]]; then
        uri=https://curl.haxx.se/ca/cacert.pem
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL --output "${HOME}/cacert.pem" "${uri}" >/dev/null 2>&1
        elif command -v http >/dev/null 2>&1; then
            http --download --output "${HOME}/cacert.pem" "${uri}" >/dev/null 2>&1
        fi
        unset uri
fi
