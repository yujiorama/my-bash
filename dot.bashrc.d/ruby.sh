#!/bin/bash
if ! command -v ruby >/dev/null 2>&1; then
    return
fi

alias be='bundle exec '
if [[ "${OS}" = "Windows_NT" ]]; then
    ruby_root_="$(dirname "$(command -v ruby)")"
    if [[ -e "${ruby_root_}/bundle.cmd" ]]; then
        alias be="${ruby_root_}/bundle.cmd exec "
        alias bundle="${ruby_root_}/bundle.cmd "
    fi
    unset ruby_root_
fi

function urlencode {
    local uri="$1"
    ruby -ruri -e "puts URI.parse('$uri').to_s"
}

function urldecode {
    local uri="$1"
    ruby -rcgi -e "puts CGI.unescape('$uri')"
}
