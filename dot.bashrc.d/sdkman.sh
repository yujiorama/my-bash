# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'sdkman' | tr '\n' ':')

export SDKMAN_DIR
SDKMAN_DIR="${HOME}/.sdkman"
source <( /bin/cat "${HOME}/.sdkman/bin/sdkman-init.sh" )
