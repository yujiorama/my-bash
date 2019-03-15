# ex: ts=4 sw=4 et filetype=sh

[[ ! -e "${HOME}/.scoop_check" ]] && touch "${HOME}/.scoop_check"

last_week=$(date --date="1 weeks ago" +"%s")
scoop_check=$(stat --format="%Y" ${HOME}/.scoop_check)
if [[ ${last_week} -gt ${scoop_check} ]]; then
    if online github.com 443; then
        scoop update 2>&1 >/dev/null
    fi
    scoop status
    touch ${HOME}/.scoop_check
fi
