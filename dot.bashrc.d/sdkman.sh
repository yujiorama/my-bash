#!/bin/bash
PATH=$(echo "$PATH" | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'sdkman' | tr '\n' ':')

export SDKMAN_DIR
SDKMAN_DIR="${HOME}/.sdkman"
# shellcheck source=/dev/null
source "${SDKMAN_DIR}/bin/sdkman-init.sh"
