WSL のセットアップ
====

## Debian

### `sudo` の設定

パスワード無しで `sudo` を使えるようにする。
新しく起動した bash でパスワードを確認されなかったら成功。

```bash
echo "$(id -u -n) ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopassword
bash -i -l
sudo ls
```

### システムの設定

```bash
sudo bash /mnt/c/path/to/setup-system.sh
```

以下をまとめて実行する。

* apt の接続先を Debian JP のミラーサイトに変更
* 基本的なパッケージの追加
  - 日本語関係のパッケージ
  - マニュアル
  - ページャー
  - エディタ
  - bash の補完
  - ユーティリティ
* タイムゾーンを変更
* ロケールを変更
* ホスト側の `C:\` を `/c` にマウント
  - Windows のファイルパスを Git Bash と同じように扱えるので便利

### ユーザー別の設定

```bash
bash /mnt/c/path/to/setup-user.sh
```

以下を実行する。

* `${HOME}/.bash_profile` を作成

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
    sudo /bin/ln -f -s ${f} /usr/local/bin/$(basename ${f})
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
sudo apt install -y git libssl-dev libreadline-dev zlib1g-dev
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
(cd ~/.rbenv && src/configure && make -C src)
source ~/.bashrc.d/ruby.sh
mkdir -p $(rbenv root)/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install 2.6.2
rbenv local 2.6.2
rbenv global
```

### SDKMAN

https://sdkman.io/

```bash
sudo apt install -y curl zip unzip
curl -s "https://get.sdkman.io" | bash
source ~/.bashrc.d/sdkman.sh
sdk install java 11.0.2-zulu
sdk install java 8.0.202-amzn
sdk use java 11.0.2-zulu
sdk install gradle 5.3.1
sdk install maven 3.6.3
```
