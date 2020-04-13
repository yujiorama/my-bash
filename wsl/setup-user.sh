#!/bin/bash

# shellcheck disable=SC1090
source <(/mnt/c/WINDOWS/system32/cmd.exe /c "set USERPROFILE" |& tail +4 | tr -d '\r' | sed -e 's/\\/\\\\/g')
host_user_home=$(wslpath -u "${USERPROFILE}")

cat - <<EOS > "${HOME}/.bash_profile"
# 必須
export HOST_USER_HOME
HOST_USER_HOME="${host_user_home}"

# dotfile の置き場所は固定
/bin/rm -f "\${HOME}/.bashrc.d"
if [[ -d "\${HOST_USER_HOME}/config-scripts/dot.bashrc.d" ]]; then
    /bin/ln -f -s "\${HOST_USER_HOME}/config-scripts/dot.bashrc.d" "\${HOME}/.bashrc.d"
fi

# 任意。あると便利だと思う
for d in work Downloads .aws .m2; do
    /bin/rm -f "\${HOME}/\${d}"
    if [[ -d "\${HOST_USER_HOME}/\${d}" ]]; then
        /bin/ln -f -s "\${HOST_USER_HOME}/\${d}" "\${HOME}/\${d}"
    fi
done

# ホスト側の C:\ を /c にマウント
if [[ -d /mnt/c ]] && [[ -d /c ]] && ! mountpoint -q /c; then
    sudo mount --bind /mnt/c /c
fi
mount | grep ' /c '

# 必須。読み込みする
[[ -e \${HOME}/.bashrc.d/.bash_profile ]] && source \${HOME}/.bashrc.d/.bash_profile
EOS


ls -l "${HOME}/.bash_profile"
