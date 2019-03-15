# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if [[ -d ${HOME}/.rbenv ]]; then
    PATH=${PATH/\/home\/y_okazawa\/.rbenv\/bin:}
    PATH=${HOME}/.rbenv/bin:${PATH}
    eval "$(rbenv init -)"
fi

if [[ -d "/c/tools/ruby26" ]]; then
    PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e '/c/tools/ruby' | tr '\n' ':')
    PATH=${PATH}:/c/tools/ruby26/bin
fi

if alias | grep -w be 2>&1 >/dev/null    ; then unalias be    ; fi
if alias | grep -w bundle 2>&1 >/dev/null; then unalias bundle; fi

if which bundle 2>&1 >/dev/null; then
    alias be='bundle exec ' 
else
    RUBY_ROOT_="$(dirname "$(which ruby)")"
    if [[ -e "${RUBY_ROOT_}/bundle.cmd" ]]; then
        alias be="${RUBY_ROOT_}/bundle.cmd exec "
        alias bundle="${RUBY_ROOT_}/bundle.cmd "
    fi
    unset RUBY_ROOT_
fi
