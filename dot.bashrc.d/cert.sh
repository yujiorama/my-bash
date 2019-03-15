if [[ ! -e ${HOME}/cacert.pem ]] ||
    [[ $(stat --format=%Y ${HOME}/cacert.pem) -lt $(date --date='1 days ago' +"%s") ]]; then
    if which curl 2>&1 >/dev/null; then
        curl -fsSL --output ${HOME}/cacert.pem https://curl.haxx.se/ca/cacert.pem 2>&1 >/dev/null
    elif which http 2>&1 >/dev/null; then
        http --download --output ${HOME}/cacert.pem https://curl.haxx.se/ca/cacert.pem 2>&1 >/dev/null
    fi
fi

export SSL_CERT_FILE
SSL_CERT_FILE=${HOME}/cacert.pem
