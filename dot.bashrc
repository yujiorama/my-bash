for f in $(find ${HOME}/.bashrc.d -type f -name \*.sh); do
    source ${f}
done

# prompt_command で複数のコマンドを実行
# http://qiita.com/tay07212/items/9509aef6dc3bffa7dd0c
#
export PROMPT_COMMAND_share_history="history -a; history -c; history -r"
if which ConEMUC64.exe >/dev/null 2>&1; then
    export PROMPT_COMMAND_conemu_storecwd="if which ConEMUC64.exe >/dev/null 2>&1; then ConEMUC64.exe -StoreCWD; fi"
fi
dispatch() {
    export EXIT_STATUS="$?" # 直前のコマンド実行結果のエラーコードを保存

    local f
    for f in ${!PROMPT_COMMAND_*}; do #${!HOGE*}は、HOGEで始まる変数の一覧を得る
        eval "${!f}" # "${!f}"は、$fに格納された文字列を名前とする変数を参照する（間接参照）
    done
    unset f
}
export PROMPT_COMMAND='dispatch'

shopt -u histappend

alias be='bundle exec'
alias ls='/bin/ls -F --color=auto --show-control-chars'
alias l='ls -la --time-style=long-iso'
alias la='ls -a --time-style=long-iso'
alias ll='ls -l --time-style=long-iso'
alias dm='docker-machine'
alias xmlstarlet='xml'
alias zstdmt='zstd -T0'
alias unzstd='zstd -d'
alias zstdcat='zstd -dcf'

if [[ ! -z "${JDK8_HOME}" ]]; then
    gradle_home="${HOME}/.gradle"
    gradle_properties="${gradle_home}/gradle.properties"
    mkdir -p ${gradle_home}
    if [ ! -e "${gradle_properties}" ]; then
        touch "${gradle_properties}"
    fi
    found=$( grep -c org.gradle.java.home ${gradle_properties} )
    if [[ 0 -eq ${found} ]]; then
        echo org.gradle.java.home=${JDK8_HOME} | sed -r -e 's|\\|/|g' >> ${gradle_properties}
    fi
fi

if [[ -d /usr/share/git/completion ]]; then
    for f in /usr/share/git/completion/*.bash /usr/share/git/completion/*.sh /mingw64/share/git/completion/*.bash; do
        source ${f}
    done
    GIT_PS1_SHOWDIRTYSTATE=
    GIT_PS1_SHOWUPSTREAM=1
    GIT_PS1_SHOWUNTRACKEDFILES=
    GIT_PS1_SHOWSTASHSTATE=1
    export PS1='\[\033]0;$TITLEPREFIX:${PWD//[^[:ascii:]]/?}\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ '
fi

if [[ -e /c/Python36/Scripts/aws_bash_completer ]]; then
    source /c/Python36/Scripts/aws_bash_completer
fi

if [[ -e ${HOME}/.pythonrc.py ]]; then
    if ! py -3 -m pip show see 2>/dev/null | grep Location; then 
        py -3 -m pip install see
    fi
    echo 'from see import see' > ${HOME}/.pythonrc.py
    export PYTHONSTARTUP="$HOME/.pythonrc.py"
fi

# try docker-machine
if which docker-machine >/dev/null 2>&1; then
    if (docker-machine ls --quiet --timeout 1 --filter state=Running --filter name=default | grep running) >/dev/null; then
        eval $(docker-machine env default | tee ${HOME}/.docker_env)
    fi
fi
# try minikube
if which minikube >/dev/null 2>&1; then
    if minikube status --profile minikube >/dev/null; then
        eval $(minikube docker-env --profile minikube | tee ${HOME}/.docker_env)
        source <(minikube completion bash)
    fi
fi
if [[ ! -z $DOCKER_HOST ]]; then
    if [[ -e "${HOME}/.docker-compose.bash" ]]; then
        source "${HOME}/.docker-compose.bash"
    fi

    if which kompose >/dev/null 2>&1; then
        source <(kompose completion bash)
    fi
fi
export COMPOSE_CONVERT_WINDOWS_PATHS=1
export DOCKER_BUILDKIT=1


kubectl config view --flatten > ${HOME}/.kube_config
source <(kubectl completion bash)

if [[ -e ${HOME}/.ssh-agent.env ]]; then
    source ${HOME}/.ssh-agent.env
else
    source <(ssh-agent -s | tee ${HOME}/.ssh-agent.env)
    for f in ${HOME}/.ssh/id_ed25519 ${HOME}/.ssh/id_rsa ${HOME}/.ssh/*.id; do
        ssh-add ${f}
    done
fi

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
export SDKMAN_DIR="${HOME}/.sdkman" \
    && source "${HOME}/.sdkman/bin/sdkman-init.sh"

if [[ ! -z "${ConEmuPID}" ]]; then
  /c/WINDOWS/system32/chcp.com 65001
fi
