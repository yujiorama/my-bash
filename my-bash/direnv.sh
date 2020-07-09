#!/bin/bash
# skip: no

if ! command -v direnv >/dev/null 2>&1;then
    return
fi

direnv hook bash > "${MY_BASH_ENV}/direnv"
ls -l "${MY_BASH_ENV}/direnv"
