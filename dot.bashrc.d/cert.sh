# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ ! -e ${HOME}/cacert.pem ]] ||
    [[ $(stat --format=%Y ${HOME}/cacert.pem) -lt $(date --date='1 days ago' +"%s") ]]; then
    if which curl >/dev/null 2>&1; then
        curl -fsSL --output ${HOME}/cacert.pem https://curl.haxx.se/ca/cacert.pem >/dev/null 2>&1
    elif which http >/dev/null 2>&1; then
        http --download --output ${HOME}/cacert.pem https://curl.haxx.se/ca/cacert.pem >/dev/null 2>&1
    fi
fi
