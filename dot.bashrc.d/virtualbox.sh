# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'VirtualBox' | tr '\n' ':')

if [[ -d "/c/Program Files/Oracle/VirtualBox" ]]; then
    PATH=${PATH}:"/c/Program Files/Oracle/VirtualBox"
fi
