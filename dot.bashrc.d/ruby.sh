PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e '/c/tools/ruby' | tr '\n' ':')
if [[ -d "/c/tools/ruby26" ]]; then
    PATH=${PATH}:/c/tools/ruby26/bin
fi
