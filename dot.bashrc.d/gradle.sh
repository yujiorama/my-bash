# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

completion="${HOME}/.gradle.completion"
uri=https://raw.githubusercontent.com/gradle/gradle-completion/master/gradle-completion.bash
[[ ! -e "${completion}" ]] && touch --date "2000-01-01" "${completion}"
curl -fsL -o "${completion}" -z "${completion}" "${uri}"
# shellcheck source=/dev/null
source "${completion}"
unset completion uri
