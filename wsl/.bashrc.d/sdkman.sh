# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

# curl -s "https://get.sdkman.io" | bash
# source ~/wsl/.bashrc.d/sdkman.sh
# sdk install java 11.0.2-zulu
# sdk install java 8.0.202-amzn
# sdk use java 11.0.2-zulu
# sdk install gradle 5.3.1
# sdk install maven 3.6.3

if [[ -d ${HOME}/.sdkman ]]; then
    export SDKMAN_DIR="${HOME}/.sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi
