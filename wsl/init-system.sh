#!/bin/bash
#
# usage:
#     echo "$(id -u -n) ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopassword
#     bash -l -i
#     sudo bash /mnt/c/path/to/setup.sh
#

if [[ 0 -ne $(id -u) ]]; then
    exit
fi

##
## apt source
##
# shellcheck disable=SC1090
source <(grep VERSION_CODENAME /etc/os-release)

if [[ -e /etc/apt/sources.list ]] && [[ ! -e /etc/apt/sources.list.bak ]]; then
    mv /etc/apt/sources.list /etc/apt/sources.list.bak
fi
cat - <<EOS | tee /etc/apt/sources.list
deb http://ftp.jp.debian.org/debian/ ${VERSION_CODENAME} main contrib non-free
deb http://ftp.jp.debian.org/debian ${VERSION_CODENAME}-updates main contrib non-free
deb http://ftp.jp.debian.org/debian ${VERSION_CODENAME}-backports main contrib non-free
deb http://security.debian.org/debian-security/ ${VERSION_CODENAME}/updates main contrib non-free
EOS

cat - <<EOS | tee /etc/apt/sources.list.d/google-cloud-sdk.list
deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main
EOS

apt update
apt upgrade -y

##
## basic
##
apt install \
    --yes \
    --no-install-recommends \
    apt-file \
    apt-transport-https \
    bash-completion \
    build-essential \
    ca-certificates \
    ca-certificates \
    cgroupfs-mount \
    curl \
    fzf \
    git \
    gnupg \
    less \
    lsb-release \
    man \
    netcat \
    openssh-client \
    pass \
    python3:any python3-xdg \
    rclone \
    rsync \
    software-properties-common \
    task-japanese \
    tree \
    unzip \
    vim-tiny \
    zip

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

apt update
apt install --yes --no-install-recommends google-cloud-sdk

apt autoremove -y
apt-file update

##
## Timezone
##
if [[ ! -e "/usr/share/zoneinfo/Japan" ]]; then
    exit
fi

echo Asia/Tokyo | tee /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

localtime="$(readlink -m /etc/localtime)"
asiatokyo="$(readlink -m /usr/share/zoneinfo/Asia/Tokyo)"
cat - <<EOS
                /etc/localtime: ${localtime}
/usr/share/zoneinfo/Asia/Tokyo: ${asiatokyo}
EOS

if [[ "${localtime}" != "${asiatokyo}" ]]; then
    exit
fi

##
## Locale
##
sed -i.bak -e 's/^# ja_JP.UTF-8.*/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
dpkg-reconfigure -f noninteractive locales
update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

##
## Mount
###
mkdir -p /c
