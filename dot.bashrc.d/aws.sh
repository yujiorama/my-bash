if which aws_completer >/dev/null 2>&1; then
    complete -C aws_completer aws
fi

if [[ -e "${HOME}/.aws/config" ]]; then
    export AWS_CONFIG_FILE
    AWS_CONFIG_FILE=${HOME}/.aws/config
fi

if [[ -e "${HOME}/.aws/credentials" ]]; then
    export AWS_SHARED_CREDENTIALS_FILE
    AWS_SHARED_CREDENTIALS_FILE="${HOME}/.aws/credentials"
fi
