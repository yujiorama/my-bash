PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e '/c/tools/ruby' | tr '\n' ':')

if [[ -d "/c/tools/ruby26" ]]; then
    PATH=${PATH}:/c/tools/ruby26/bin
fi

if alias | grep -w be >/dev/null 2>&1; then unalias be; fi
if alias | grep -w bundle >/dev/null 2>&1; then unalias bundle; fi

if which bundle >/dev/null 2>&1; then
    alias be='bundle exec ' 
else
    RUBY_ROOT_="$(dirname "$(which ruby)")"
    if [[ -e "${RUBY_ROOT_}/bundle.cmd" ]]; then
        alias be="${RUBY_ROOT_}/bundle.cmd exec "
        alias bundle="${RUBY_ROOT_}/bundle.cmd "
    fi
    unset RUBY_ROOT_
fi
