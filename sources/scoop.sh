# shellcheck shell=bash

if [[ "${OS}" = "Linux" ]]; then
    return
fi

cat - <<EOS > "${MY_BASH_COMPLETION}/scoop"
function _scoop-completion {
    local compword_ candidates_
    compword_="${COMP_WORDS[${COMP_CWORD}]}"
    candidates_=$(scoop help | sed -r -e '/^$/d' -e '/.*(Usage|Some useful|to get help).*/d' | awk '{print $1}' | tr '\n' ' ')
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "${candidates_}" -- "${compword_}"))
}

complete -o default -o nospace -F _scoop-completion scoop
EOS


function scoop-force-cleanup {
    scoop list  | tail +3 | awk '{if ($1 != "") {print $1}}' | while read -r app; do
        scoop cache rm "${app}" 2>/dev/null
        scoop cleanup "${app}" 2>/dev/null
    done
}

function scoop-update-status {
    scoop update >/dev/null 2>&1
    scoop status
}

scoop-update-status

export SCOOP
SCOOP="$(cygpath -ma "${HOME}/scoop")"

if mysql_workbench_dir="$(scoop prefix mysql-workbench)" \
    && [[ -n "${mysql_workbench_dir}" ]]; then
    export PATH
    PATH="${PATH}":"$(cygpath -ua "${mysql_workbench_dir}")"
    unset mysql_workbench_dir
fi
