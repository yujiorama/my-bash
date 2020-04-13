#!/bin/bash

if [[ "${OS}" = "Linux" ]]; then
    return
fi

cat - <<EOS > "${HOME}/.completion/scoop"
function _scoop-completion {
    local compword_ candidates_
    compword_="${COMP_WORDS[${COMP_CWORD}]}"
    candidates_=$(scoop help | sed -r -e '/^$/d' -e '/.*(Usage|Some useful|to get help).*/d' | awk '{print $1}' | tr '\n' ' ')
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "${candidates_}" -- "${compword_}"))
}

complete -o default -o nospace -F _scoop-completion scoop
EOS

#
# scoop update app が最新バージョンの発見に失敗するワークアラウンド。
# 単純にバージョン番号を文字列の昇順で整列して判断してるので、バージョン番号の付け方によっては新しいバージョンを見つけられない。
#
function _scoop-target-version {
    local app version
    app="$1"
    if [[ -z "${app}" ]]; then
        return
    fi
    version="$2"

    local info installed manifest target_version
    info="$(scoop info "${app}")"

    if installed="$(echo "${info}" | grep 'Installed:' | tr '[:lower:]' '[:upper:]' | tr -d ' ' | cut -d ':' -f 2)" \
        && [[ "${installed}" = "NO" ]]; then
        echo "[${app}] not installed" >/dev/stderr
        return
    fi

    if manifest="$(echo "${info}" | grep -A 1 "Manifest:" | tail -n 1 | tr -d ' ')"  \
        && [[ -z "${manifest}" ]]; then
        echo "[${app}] manifest file error" >/dev/stderr
        return
    fi

    if [[ ! -e "${manifest}" ]]; then
        echo "[${app}] ${manifest} not found" >/dev/stderr
        return
    fi

    if [[ -n "${version}" ]]; then
        echo -n "${version}"
        return
    fi

    if target_version="$(jq -r .version < "${manifest}")" && [[ -z "${target_version}" ]]; then
        echo "[${app}] version error" >/dev/stderr
        return
    fi

    echo -n "${target_version}"
    return
}

function scoop-force-update {
    local app version
    app="$1"
    if [[ -z "${app}" ]]; then
        return
    fi
    version="$2"

    local target_version
    target_version="$(_scoop-target-version "${app}" "${version}")"
    if [[ -z "${target_version}" ]]; then
        return
    fi

    local prefix current_version
    if prefix="$(scoop prefix "${app}")" && [[ ! -e "${prefix}" ]]; then
        echo "[${app}] prefix error: ${prefix}" >/dev/stderr
        return
    fi

    if current_version="$(basename "$(readlink -m "${prefix}")")" && [[ -z "${current_version}" ]]; then
        echo "[${app}] current version error" >/dev/stderr
        return
    fi

    if [[ "${target_version}" = "${current_version}" ]]; then
        echo "[${app}] updated" >/dev/stderr
        return
    fi

    scoop uninstall "${app}"
    scoop install -f "${app}@${target_version}"
}

function scoop-force-cleanup {
    scoop list  | tail +3 | awk '{if ($1 != "") {print $1}}' | while read -r app; do
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
