# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

open() {
    explorer.exe "$1"
}
iview() {
    if ! command -v "${HOST_USER_HOME}/scoop/shims/irfanview.exe" >/dev/null 2>&1; then
        echo "${HOST_USER_HOME}/scoop/shims/irfanview.exe not found"
        return
    fi
    "${HOST_USER_HOME}/scoop/shims/irfanview.exe" "$1"
}
subl() {
    if ! command -v "${HOST_USER_HOME}/scoop/shims/subl.exe" >/dev/null 2>&1; then
        echo "${HOST_USER_HOME}/scoop/shims/subl.exe not found"
        return
    fi
    "${HOST_USER_HOME}/scoop/shims/subl.exe" "$1"
}
winmerge() {
    local a b
    a=$1;shift
    b=$1;

    if ! command -v "${HOST_USER_HOME}/scoop/shims/winmergeu.exe" >/dev/null 2>&1; then
        echo "${HOST_USER_HOME}/scoop/shims/winmergeu.exe not found"
        return
    fi
    "${HOST_USER_HOME}/scoop/shims/winmergeu.exe" "${a}" "${b}"
}

code() {
    if ! command -v "${HOST_USER_HOME}/scoop/apps/vscode/current/Code.exe" >/dev/null 2>&1; then
        return
    fi
    "${HOST_USER_HOME}/scoop/apps/vscode/current/Code.exe" "$@"
}

uuidgen() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen
        return
    fi
    if command -v ruby >/dev/null 2>&1; then
        ruby -rsecurerandom -e 'puts SecureRandom.uuid'
        return
    fi
}
