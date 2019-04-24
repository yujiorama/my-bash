# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'sdkman' | tr '\n' ':')

export SDKMAN_DIR="${HOME}/.sdkman" \
    && source "${HOME}/.sdkman/bin/sdkman-init.sh"
PATH=${PATH//C:\\Users\\y_okazawa\\.sdkman\\/\/c\/Users\/y_okazawa\/.sdkman\/}
