#!/bin/bash
#
# 元ネタ
# おそらくはそれさえも平凡な日々 > bashでdotenvファイルを環境変数に読み出す
# https://songmu.jp/riji/entry/2019-06-14-bash-dotenv.html
#

#
# Usage
#
# 何も指定しないパターン
# $ diff <(bash -c "env | sort") <(~/dotenv.sh bash -c "env | sort")
#
# 環境変数 AAA を .env に定義するパターン
# $ echo AAA=BBB > .env
# $ diff <(bash -c "env | sort") <(~/dotenv.sh bash -c "env | sort")
# 2a3
# > AAA=BBB
#
# 環境変数 DOTENV に現在のディレクトリの .env を指定するパターン
# $ diff <(bash -c "env | sort") <(DOTENV=${PWD}/.env ~/dotenv.sh bash -c "env | sort")
# 2a3
# > AAA=BBB
# 41a43
# > DOTENV=/c/Users/y_okazawa/tmp/.env
#

dotenv() {
    original_env="$(declare -x)"
    
    ### dotenv like
    DOTENV="${DOTENV:-${PWD}/.env}"
    
    if [[ -e "${DOTENV}" ]]; then
        set -o allexport
        # shellcheck disable=SC1090
        source "${DOTENV}"
        set +o allexport
    fi
    
    eval "${original_env}"
    
    exec "$@"
}

if [[ "dotenv" == "$(basename $0 .sh)" ]]; then
    dotenv "$@"
fi
