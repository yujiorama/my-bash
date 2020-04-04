# ex: ts=4 sw=4 et filetype=sh

if ! command -v scoop >/dev/null 2>&1; then
    return
fi

if mysql_workbench_dir="$(scoop prefix mysql-workbench)" \
    && [[ -n "${mysql_workbench_dir}" ]]; then
    export PATH
    PATH="${PATH}":"$(cygpath -ua "${mysql_workbench_dir}")"
    unset mysql_workbench_dir
fi

export SCOOP
SCOOP="$(cygpath -ma "${HOME}/scoop")"

#
# scoop update app が最新バージョンの発見に失敗するワークアラウンド。
# 単純にバージョン番号を文字列の昇順で整列して判断してるので、バージョン番号の付け方によっては新しいバージョンを見つけられない。
#
function scoop-update {
    local app installed manifest version current_version
    app="$1"
    if [[ -z "${app}" ]]; then
        return
    fi

    if installed="$(scoop info "${app}" | grep 'Installed:' | tr '[:lower:]' '[:upper:]' | tr -d ' ' | cut -d ':' -f 2)" \
        && [[ "${installed}" = "NO" ]]; then
        echo "[${app}] not installed"
        return
    fi

    if manifest="$(scoop info "${app}" | grep -A 1 "Manifest:" | tail -n 1 | tr -d ' ')"  \
        && [[ -z "${manifest}" ]]; then
        echo "[${app}] manifest file error"
        return
    fi

    if [[ ! -e "${manifest}" ]]; then
        echo "[${app}] ${manifest} not found"
        return
    fi

    if version="$(jq -r .version < "${manifest}")" && [[ -z "${version}" ]]; then
        echo "[${app}] version error"
        return
    fi

    if prefix="$(scoop prefix "${app}")" && [[ ! -e "${prefix}" ]]; then
        echo "[${app}] prefix error"
        return
    fi

    if current_version="$(basename "$(readlink -m "${prefix}")")" && [[ -z "${current_version}" ]]; then
        echo "[${app}] current version error"
        return
    fi

    if [[ "${version}" = "${current_version}" ]]; then
        echo "[${app}] updated"
        return
    fi

    scoop update "${app}"@"${version}"
}

function scoop-update-status {
    scoop update >/dev/null 2>&1
    scoop status
}

scoop-update-status
