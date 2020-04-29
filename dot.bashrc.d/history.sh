#!/bin/bash
export HISTSIZE
HISTSIZE=1000000
export HISTCONTROL
HISTCONTROL=ignoredups
export HISTTIMEFORMAT
HISTTIMEFORMAT='%Y-%m-%d %T '

# prompt_command で複数のコマンドを実行
# http://qiita.com/tay07212/items/9509aef6dc3bffa7dd0c
#
export PROMPT_COMMAND_share_history="history -a; history -c; history -r"

if [[ -n "${ConEmuPID}" ]] && command -v ConEMUC64.exe >/dev/null 2>&1; then
    export PROMPT_COMMAND_conemu_storecwd="ConEMUC64.exe -StoreCWD"
fi

dispatch() {
    export EXIT_STATUS="$?" # 直前のコマンド実行結果のエラーコードを保存

    local command
    for command in ${!PROMPT_COMMAND_*}; do
        eval "${!command}"
    done
}
export PROMPT_COMMAND
PROMPT_COMMAND='dispatch'
