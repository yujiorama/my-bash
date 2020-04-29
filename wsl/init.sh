#!/bin/bash

distribution="${1}"
if [[ -z "${distribution}" ]]; then
    distribution="$(wsl --list | iconv -f UTF-16LE -t UTF-8 | grep '既定' | cut -d ' ' -f 1)"
    if [[ -z "${distribution}" ]]; then
        exit
    fi
fi

wsl --upgrade "${distribution}"

# shellcheck disable=SC2016
MSYS_NO_PATHCONV=1 wsl --distribution "${distribution}" bash -c 'echo "$(id -u -n) ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopassword'

MSYS_NO_PATHCONV=1 wsl --distribution "${distribution}" --user root bash "/mnt/$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")/init-system.sh"

host_user_home="$(cygpath -ua "${HOME}")"
dot_bashrc_d="$(dirname "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")")/dot.bashrc.d"

# shellcheck disable=SC2016
cat - <<EOS | MSYS_NO_PATHCONV=1 wsl --distribution "${distribution}" bash -c 'cat - > ${HOME}/.bash_profile; ls -l ${HOME}/.bash_profile'
# ホスト側の C:\ を /c にマウント
if [[ -d /mnt/c ]] && [[ -d /c ]] && ! mountpoint -q /c; then
    sudo mount --bind /mnt/c /c
fi
mount | grep ' /c '

# 必須
export HOST_USER_HOME
HOST_USER_HOME="${host_user_home}"

# dotfile の置き場所は固定
/bin/rm -rf "\${HOME}/.bashrc.d"
if [[ -d "${dot_bashrc_d}" ]]; then
    /bin/ln -f -s "${dot_bashrc_d}" "\${HOME}/.bashrc.d"
fi

# 任意。あると便利だと思う
for d in work Downloads .aws .m2; do
    /bin/rm -rf "\${HOME}/\${d}"
    if [[ -d "\${HOST_USER_HOME}/\${d}" ]]; then
        /bin/ln -f -s "\${HOST_USER_HOME}/\${d}" "\${HOME}/\${d}"
    fi
done

# 必須。読み込みする
[[ -e \${HOME}/.bashrc.d/.bash_profile ]] && source \${HOME}/.bashrc.d/.bash_profile
EOS
