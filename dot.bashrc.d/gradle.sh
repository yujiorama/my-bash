#!/bin/bash
completion="${HOME}/.gradle.completion"
uri=https://raw.githubusercontent.com/gradle/gradle-completion/master/gradle-completion.bash
[[ ! -e "${completion}" ]] && touch --date "2000-01-01" "${completion}"
curl -fsL -o "${completion}" -z "${completion}" "${uri}"
# shellcheck source=/dev/null
source "${completion}"
unset completion uri
