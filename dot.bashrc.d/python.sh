# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e 'Python' | tr '\n' ':')

if [[ -d "/c/Python37" ]]; then
    PATH=${PATH}:${HOME}/.local/bin
    PATH=${PATH}:$(cygpath --unix ${APPDATA}/Python/Python37/Scripts)
    PATH=${PATH}:/c/Python37/Scripts
    PATH=${PATH}:/c/Python37
    PYTHON="py -3"
fi

if [[ -d "${HOME}/scoop/apps/python/current" ]]; then
    PATH=${PATH}:${HOME}/.local/bin
    PATH=${PATH}:$(cygpath --unix ${APPDATA}/Python/Python37/Scripts)
    PATH=${PATH}:${HOME}/scoop/apps/python/current/Scripts
    PATH=${PATH}:${HOME}/scoop/apps/python/current
    PYTHON=python3
fi

if ! which "${PYTHON}" >/dev/null 2>&1; then
    return
fi

export PYTHONIOENCODING
PYTHONIOENCODING=utf-8

export PIPENV_VENV_IN_PROJECT
PIPENV_VENV_IN_PROJECT=true

if online pypi.org 443; then
    for pkg in see awscli httpie; do
        ${PYTHON} -m pip install --user --progress-bar off --no-color --timeout 3 ${pkg} >/dev/null 2>&1 &
    done
    wait
fi

echo 'from see import see' > ${HOME}/.pythonrc.py
export PYTHONSTARTUP
PYTHONSTARTUP="$HOME/.pythonrc.py"

if which aws_completer >/dev/null 2>&1; then
    complete -C aws_completer aws
fi
