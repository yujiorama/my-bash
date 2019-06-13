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

if [[ -d "${HOME}/bin/ruby/current" ]]; then
    PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e '.ruby.current' | tr '\n' ':')
    PATH=${PATH}:${HOME}/bin/ruby/current/bin
fi

if alias | grep -w be >/dev/null 2>&1    ; then unalias be    ; fi
if alias | grep -w bundle >/dev/null 2>&1; then unalias bundle; fi

if which bundle >/dev/null 2>&1; then
    alias be='bundle exec ' 
elif which ruby >/dev/null 2>&1; then
    RUBY_ROOT_="$(dirname "$(which ruby)")"
    if [[ -e "${RUBY_ROOT_}/bundle.cmd" ]]; then
        alias be="${RUBY_ROOT_}/bundle.cmd exec "
        alias bundle="${RUBY_ROOT_}/bundle.cmd "
    fi
    unset RUBY_ROOT_
else
    :
fi
