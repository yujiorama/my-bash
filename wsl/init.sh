#!/bin/bash

distribution="${1}"
if [[ -z "${distribution}" ]]; then
    distribution="$(wsl --list | iconv -f UTF-16LE -t UTF-8 | grep '既定' | cut -d ' ' -f 1)"
    if [[ -z "${distribution}" ]]; then
        exit
    fi
fi

wsl --set-version "${distribution}" 2

# shellcheck disable=SC2016
MSYS_NO_PATHCONV=1 wsl --distribution "${distribution}" bash -c 'echo "$(id -u -n) ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopassword'

MSYS_NO_PATHCONV=1 wsl --distribution "${distribution}" --user root bash "/mnt/$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")/init-system.sh"

host_user_home="$(cygpath -ua "${HOME}")"
my_bash_dir="$(dirname "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")")"
my_bash_dir_name=$(basename "${my_bash_dir}")

# shellcheck disable=SC2016
cat - <<EOS | MSYS_NO_PATHCONV=1 wsl --distribution "${distribution}" bash -c 'cat - > ${HOME}/.bash_profile; ls -l ${HOME}/.bash_profile'

[[ -e "\${HOME}/.bashrc" ]] && source "\${HOME}/.bashrc"

# ホスト側の C:\ を /c にマウント
if [[ -d /mnt/c ]] && [[ -d /c ]] && ! mountpoint -q /c; then
    sudo mount --bind /mnt/c /c
fi
mount | grep ' /c '

# 必須
export HOST_USER_HOME
HOST_USER_HOME="${host_user_home}"

# dotfile の置き場所は固定
/bin/rm -rf "\${HOME}/${my_bash_dir_name}"
if [[ -d "${my_bash_dir}" ]]; then
    /bin/ln -f -s "${my_bash_dir}" "\${HOME}/${my_bash_dir_name}"
fi

# 任意。あると便利だと思う
for d in work Downloads .aws .m2; do
    /bin/rm -rf "\${HOME}/\${d}"
    if [[ -d "\${HOST_USER_HOME}/\${d}" ]]; then
        /bin/ln -f -s "\${HOST_USER_HOME}/\${d}" "\${HOME}/\${d}"
    fi
done

for c in .config/rclone/rclone.conf; do
    /bin/rm -rf "\${HOME}/\${c}"
    if [[ -e "\${HOST_USER_HOME}/\${c}" ]]; then
        cat "\${HOST_USER_HOME}/\${c}" > "\${HOME}/\${c}"
    fi
done

# 必須。読み込みする
[[ -e \${HOME}/${my_bash_dir_name}/init.sh ]] && source \${HOME}/${my_bash_dir_name}/init.sh
EOS

cat - <<EOS > "${USERPROFILE}/.wslconfig"
[wsl2]
memory=$(grep MemTotal /proc/meminfo | awk '{printf("%d",0.5*$2/1024)}')MB
processors=$(grep -c 'cpu cores' /proc/cpuinfo)
swap=$(grep MemTotal /proc/meminfo | awk '{printf("%d",0.1*$2/1024)}')MB
localhostForwarding=true
EOS
