PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'sdkman' | tr '\n' ':')

export SDKMAN_DIR="${HOME}/.sdkman" \
    && source "${HOME}/.sdkman/bin/sdkman-init.sh"
PATH=${PATH//C:\\Users\\y.okazawa\\.sdkman\\/\/c\/Users\/y.okazawa\/.sdkman\/}
