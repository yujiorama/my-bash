PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'Python' | tr '\n' ':')

if [[ -d "/c/Python37" ]]; then
    PATH=${PATH}:${HOME}/.local/bin
    PATH=${PATH}:/c/Python37
    PATH=${PATH}:/c/Python37/Scripts
    PATH=${PATH}:$(cygpath --unix ${APPDATA}/Python/Python37/Scripts)
fi

export PYTHONIOENCODING
PYTHONIOENCODING=utf-8

export PIPENV_VENV_IN_PROJECT
PIPENV_VENV_IN_PROJECT=true

online_=true
if which tiny-nc >/dev/null 2>&1; then
    if [[ $(tiny-nc pypi.org 443; echo $?) -eq 0 ]] &&
       [[ $(tiny-nc files.pythonhosted.org 443; echo $?) -eq 0 ]]; then
        online_=true
    else
        online_=false
    fi
fi

if [[ "${online_}" = "true" ]]; then
    for pkg in see awscli httpie; do
        if ! py -3 -m pip show ${pkg} 2>/dev/null | grep Location; then 
            py -3 -m pip install --user ${pkg}
        fi
    done
fi
unset online_

if [[ -e ${HOME}/.pythonrc.py ]]; then
    echo 'from see import see' > ${HOME}/.pythonrc.py
    export PYTHONSTARTUP
    PYTHONSTARTUP="$HOME/.pythonrc.py"
fi

if which aws_completer >/dev/null 2>&1; then
    complete -C aws_completer aws
fi
