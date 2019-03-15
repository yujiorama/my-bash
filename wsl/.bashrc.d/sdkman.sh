# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -d ${HOME}/.sdkman ]]; then
    export SDKMAN_DIR="${HOME}/.sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi
