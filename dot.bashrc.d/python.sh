PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'Python' | tr '\n' ':')

if [[ -d "/c/Python37" ]]; then
	PATH=${PATH}:/c/Python37
	PATH=${PATH}:/c/Python37/Scripts
	PATH=${PATH}:$(cygpath --unix ${APPDATA}/Python/Python37/Scripts)
fi

export PYTHONIOENCODING=utf-8

if [[ -e ${HOME}/.pythonrc.py ]]; then
    if ! py -3 -m pip show see 2>/dev/null | grep Location; then 
        py -3 -m pip install see
    fi
    echo 'from see import see' > ${HOME}/.pythonrc.py
    export PYTHONSTARTUP="$HOME/.pythonrc.py"
fi

if which aws_completer >/dev/null 2>&1; then
    complete -C aws_completer aws
fi
