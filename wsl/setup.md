WSL のセットアップ
====

## Debian

### 参考リンク

* https://www.atmarkit.co.jp/ait/articles/1810/26/news035.html
* https://serverfault.com/questions/362903/how-do-you-set-a-locale-non-interactively-on-debian-ubuntu

### 最初にやること

パスワード無しで `sudo` を使えるようにする。

```bash
echo "$(id -u -n) ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopassword
```

APT の接続先を Debian JP のミラーサイトに変更する。

```bash
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
debian_release="$(grep -w VERSION /etc/os-release | sed -r -e 's/.*\((.+)\).*/\1/')"
cat <<EOS | sudo tee /etc/apt/sources.list
deb http://ftp.jp.debian.org/debian/ ${debian_release} main contrib non-free
deb http://ftp.jp.debian.org/debian ${debian_release}-updates main contrib non-free
EOS
```

とりあえず更新。

```bash
sudo apt update
sudo apt upgrade -y
```

パッケージを追加。

* 日本語関係のパッケージ
* マニュアル
* ページャー
* エディタ

```bash
sudo apt install -y task-japanese man less vim-tiny
```

ロケールとタイムゾーンを日本に変更。

```bash
echo Asia/Tokyo | sudo tee /etc/timezone \
  && sudo dpkg-reconfigure -f noninteractive tzdata
sudo sed -i.bak -e 's/^# ja_JP.UTF-8.*/ja_JP.UTF-8 UTF-8/' /etc/locale.gen \
  && echo LANG=ja_JP.UTF-8 | sudo tee /etc/default/locale \
  && sudo dpkg-reconfigure -f noninteractive locales \
  && sudo update-locale LANG=ja_JP.UTF-8
```

`$HOME/.bash_profile` にホスト側の情報を追加。

```bash
# 必須
export HOST_USER_HOME
HOST_USER_HOME="/mnt/c/Users/!!ここにWindowsのユーザー名!!"

# ホスト側の置き場所はともかく WSL 側の置き場所は固定
if ! /bin/mountpoint -q "${HOME}/.bashrc.d"; then
    /bin/mkdir -p "${HOME}/.bashrc.d"
    /usr/bin/sudo /bin/mount --bind "${HOST_USER_HOME}/config-scripts/wsl/.bashrc.d" "${HOME}/.bashrc.d"
fi

# 任意。あると便利だと思う
for d in work Downloads .aws .m2; do
    if ! /bin/mountpoint -q "${HOME}/${d}"; then
        /bin/mkdir -p "${HOME}/${d}"
        /usr/bin/sudo /bin/mount --bind "${HOST_USER_HOME}/${d}" "${HOME}/${d}"
    fi
done

# これも任意。Git bash は /c から始まるパス文字列を扱うのであると便利。
if ! /bin/mountpoint -q /c; then
    /usr/bin/sudo /bin/mkdir -p /c
    /usr/bin/sudo /bin/mount --bind /mnt/c /c
fi

# 必須。読み込みする
[[ -e ${HOME}/.bashrc.d/.bash_profile ]] && source ${HOME}/.bashrc.d/.bash_profile
```

### 後からやること

#### Docker

https://docs.docker.com/install/linux/docker-ce/debian/

```bash
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $(id -u -n)
```

#### Kubernetes

https://kubernetes.io/docs/tasks/tools/install-kubectl/

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod 755 kubectl
sudo mv kubectl /usr/local/bin/kubectl
```

#### Podman

https://github.com/containers/libpod/blob/master/docs/tutorials/podman_tutorial.md

#### Buildah

https://github.com/containers/buildah/blob/master/install.md

#### Go

https://tecadmin.net/install-go-on-debian/

```bash
sudo mkdir -p /usr/local/share
curl -fsSL https://dl.google.com/go/go1.12.linux-amd64.tar.gz | sudo tar -C /usr/local/share -xzf -
for f in $(find /usr/local/share/go/bin -type f); do
    sudo ln -f -s ${f} /usr/local/bin/$(basename ${f})
done
```

### LaTeX

```bash
sudo apt install -y --no-install-recommends \
  texlive-lang-japanese texlive-fonts-recommended texlive-latex-extra lmodern fonts-lmodern tex-gyre fonts-texgyre texlive-pictures \
  ghostscript gsfonts zip ruby-zip ruby-nokogiri mecab ruby-mecab mecab-ipadic-utf8 poppler-data cm-super \
  graphviz gnuplot python-blockdiag python-aafigure
sudo apt-get clean
```

### Ruby

https://github.com/rbenv/rbenv

https://github.com/rbenv/ruby-build

```bash
sudo apt install -y libssl-dev libreadline-dev zlib1g-dev
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
source ~/wsl/.bashrc.d/ruby.sh
mkdir -p $(rbenv root)/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install 2.6.2
rbenv global
```

### SDKMAN

https://sdkman.io/

```bash
curl -s "https://get.sdkman.io" | bash
source ~/wsl/.bashrc.d/sdkman.sh
sdk install java 11.0.2-zulu
sdk install java 8.0.202-amzn
sdk use java 11.0.2-zulu
sdk install gradle 5.3.1
sdk install maven 3.6.3
```
