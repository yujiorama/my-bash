# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

alias ls='/bin/ls -F --color=auto --show-control-chars '
alias l='ls -la --time-style=long-iso '
alias la='ls -a --time-style=long-iso '
alias ll='ls -l --time-style=long-iso '
if which xml >/dev/null 2>&1; then
    alias xmlstarlet='xml '
fi
if which zstd >/dev/null 2>&1; then
    alias zstdmt='zstd -T0 '
    alias unzstd='zstd -d '
    alias zstdcat='zstd -dcf '
fi
