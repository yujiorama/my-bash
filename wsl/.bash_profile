# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

[[ -e ${HOME}/.bashrc ]] && source ${HOME}/.bashrc

for d in work Downloads .aws .m2 wsl; do
    if ! mountpoint -q ${HOME}/${d}; then
        mkdir -p ${HOME}/${d}
        sudo mount --bind /mnt/c/Users/y.okazawa/${d} ${HOME}/${d}
    fi
done

if ! mountpoint -q /c; then
    sudo mkdir -p /c
    sudo mount --bind /mnt/c /c
fi

for f in $(find ${HOME}/wsl -type f -a \(-name \*.sh -o -name \*.env \)); do
    source ${f}
done

echo "Startup Time: $SECONDS sec"

