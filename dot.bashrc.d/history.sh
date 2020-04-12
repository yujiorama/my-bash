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

    local f
    for f in ${!PROMPT_COMMAND_*}; do #${!HOGE*}は、HOGEで始まる変数の一覧を得る
        eval "${!f}" # "${!f}"は、$fに格納された文字列を名前とする変数を参照する（間接参照）
    done
    unset f
}
export PROMPT_COMMAND='dispatch'

shopt -u histappend
