#!/bin/bash

if ! command -v ruby >/dev/null 2>&1; then
    return
fi

if command -v rbenv >/dev/null 2>&1; then
    # shellcheck disable=SC1090
    source <(rbenv init -)
fi

if command -v bundle >/dev/null 2>&1; then
    alias be='bundle exec '
fi

if command -v bundle.cmd >/dev/null 2>&1; then
    # shellcheck disable=SC2139
    alias be="$(command -v bundl.cmd) exec "
    # shellcheck disable=SC2139
    alias bundle="$(command -v bundl.cmd) "
fi
