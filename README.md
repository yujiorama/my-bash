config-scripts
====

## Environment

Windows 10

## 使い分け

* Chocolatey
    - `Scoop` にパッケージが無いソフトウェアを導入するときに使うことがある
    - `Visual Studio` はこちらじゃないとなんか都合が悪かった･･･
* Scoop
    - 大抵のソフトウェアはあるし自分で定義ファイルも作れる

## 使い方

### 0. このリポジトリの clone

適当な場所にこのリポジトリを clone します。

以降の説明では `${HOME}/windows-gitbash-config` に clone したことにします。

### 1. `Chocolatey` のインストール

[Installation](https://chocolatey.org/install)

管理者として起動した PowerShell で次のスクリプトを実行します。

`Set-ExecutionPolicy Bypass -Scope Process -Force;` は、今のプロセスに限り署名されていない `PowerShell` スクリプトを実行できるよう制限を緩めるためのコマンドレットです。

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

そしてもろもろのソフトウェアをインストールします。

```ps1
cinst -y adobereader
```

Visual Studio のインストールは結局よくわかりません。
Visual Studio Installer が自動更新してしまうし、ワークロードと追加するコンポーネントが多すぎるしで、何回も繰り返したくはないのです･･･

もしどうしても Chocolatey で管理したいときはこちらの説明を参考にしてください。

[ChocolateyPackages/EXAMPLES.md](https://github.com/jberezanski/ChocolateyPackages/blob/master/chocolatey-visualstudio.extension/EXAMPLES.md)

完了したら PowerShell は閉じます。

そしてたぶん Windows の再起動が必要です。

### 2. `Scoop` のインストール

[Scoop](https://scoop.sh/)

普通のユーザーとして起動した PowerShell で次のスクリプトを実行します。

```ps1
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
```

最初に Git が必要です。
```ps1
scoop install git
```

その次に bucket を追加します。

```ps1
scoop bucket add extras
scoop bucket add java
scoop bucket add versions
scoop bucket add jetbrains
scoop bucket add dev-scoop https://bitbucket.org/yujiorama/scoop
scoop update
```

残りのソフトウェアをインストールします。

```ps1
scoop install sudo launchy sysinternals tortoisesvn googlechrome firefox thunderbird adopt8-hotspot adopt11-hotspot openjdk15 go nodejs python IntelliJ-IDEA-Ultimate sublime-text vscode winmerge vagrant docker docker-compose kubectl minikube openvpn putty winscp 7zip zip unzip zstd mysql-workbench fzf jq
```

### 3. Git Bash の構成

`.bash_profile` を編集してこのリポジトリのスクリプトを読み込むようにします。

最後に次の行を追加するだけです。

```bash
[ -e "${HOME}/windows-gitbash-config/init.sh" ] && source "${HOME}/windows-gitbash-config/init.sh"
```

### 4. WSL の構成

Git Bash のプロンプトで次のようにスクリプトを実行します。
途中で WSL 環境で `sudo` を実行するため WSL 環境のユーザーに設定したパスワードの入力が求められるので注意。

```bash
${HOME}/windows-gitbash-config/wsl/init.sh
```
