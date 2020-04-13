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
cat <<EOS | tee /etc/apt/sources.list
deb http://ftp.jp.debian.org/debian/ ${VERSION_CODENAME} main contrib non-free
deb http://ftp.jp.debian.org/debian ${VERSION_CODENAME}-updates main contrib non-free
deb http://ftp.jp.debian.org/debian ${VERSION_CODENAME}-backports main contrib non-free
deb http://security.debian.org/debian-security/ ${VERSION_CODENAME}/updates main contrib non-free
EOS
apt update
apt upgrade -y

##
## basic
##
apt install -y \
    task-japanese \
    man \
    less \
    vim-tiny \
    bash-completion \
    curl \
    ca-certificates \
    zip \
    unzip \
    netcat \
    rsync \
    pass \
    git \
    gnupg \
    tree \
    python3:any python3-xdg \
    lsb-release

apt autoremove -y

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
update-locale LANG=ja_JP.UTF-8

##
## Mount
###
mkdir -p /c
