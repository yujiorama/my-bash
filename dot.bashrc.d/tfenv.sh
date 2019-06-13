# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

# https://github.com/tfutils/tfenv

if which git >/dev/null 2>&1; then
    if [[ ! -d ${HOME}/.tfenv ]]; then
        git clone https://github.com/tfutils/tfenv.git ${HOME}/.tfenv
    else
        git --git-dir=${HOME}/.tfenv/.git pull
    fi

    PATH=$(echo $PATH | tr ':' '\n' | grep -v -e '^$' | grep -v -e '.tfenv' | tr '\n' ':')
    PATH=${HOME}/.tfenv/bin:${PATH}
    which tfenv
fi
