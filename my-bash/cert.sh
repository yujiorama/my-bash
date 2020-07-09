#!/bin/bash

unset SSL_CERT_FILE
download_new_file "https://curl.haxx.se/ca/cacert.pem" "${HOME}/cacert.pem"
if [[ -e "${HOME}/cacert.pem" ]]; then
    export SSL_CERT_FILE
    SSL_CERT_FILE=${HOME}/cacert.pem
    if [[ "${OS}" != "Linux" ]]; then
    	SSL_CERT_FILE="$(cygpath -ma "${SSL_CERT_FILE}")"
    fi
fi
