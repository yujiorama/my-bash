if [[ -e ${HOME}/.pythonrc.py ]]; then
    if ! py -3 -m pip show see 2>/dev/null | grep Location; then 
        py -3 -m pip install see
    fi
    echo 'from see import see' > ${HOME}/.pythonrc.py
    export PYTHONSTARTUP="$HOME/.pythonrc.py"
fi
