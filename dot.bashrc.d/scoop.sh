# ex: ts=4 sw=4 et filetype=sh

[[ ! -e "${HOME}/.scoop_check" ]] && touch "${HOME}/.scoop_check"

last_week=$(date --date="1 weeks ago" +"%s")
scoop_check=$(stat --format="%Y" ${HOME}/.scoop_check)
if [[ ${last_week} -gt ${scoop_check} ]]; then
    if online github.com 443; then
        scoop update >/dev/null 2>&1
    fi
    touch "${HOME}/.scoop_check"
fi
scoop status
unset last_week scoop_check

if [[ -n "$(scoop prefix mysql-workbench)" ]]; then
    export PATH
    PATH="${PATH}":"$(cygpath -ua "$(scoop prefix mysql-workbench)")"
fi
