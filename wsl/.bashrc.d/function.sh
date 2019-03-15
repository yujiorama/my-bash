# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

subl() {
    wsl_file=$1
    if [[ ! -e ${wsl_file} ]]; then
        touch ${wsl_file}
    fi
    if ! mountpoint -q $(readlink -f ${wsl_file} | cut -d '/' -f 1,2,3,4); then
        return
    fi
    windows_file=c:/Users/y.okazawa/$(readlink -f ${wsl_file} | cut -d '/' -f 4-)
    "/mnt/c/Users/y.okazawa/scoop/shims/subl.exe" ${windows_file}
}
code() {
    wsl_file=$1
    if [[ ! -e ${wsl_file} ]]; then
        touch ${wsl_file}
    fi
    if ! mountpoint -q $(readlink -f ${wsl_file} | cut -d '/' -f 1,2,3,4); then
        return
    fi
    windows_file=c:/Users/y.okazawa/$(readlink -f ${wsl_file} | cut -d '/' -f 4-)
    /mnt/c/Users/y.okazawa/scoop/shims/code.exe ${windows_file}
}

