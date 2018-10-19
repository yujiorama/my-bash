if [[ -e ${HOME}/.ssh-agent.env ]]; then
    source ${HOME}/.ssh-agent.env
else
    source <(ssh-agent -s | tee ${HOME}/.ssh-agent.env)
    for f in ${HOME}/.ssh/id_ed25519 ${HOME}/.ssh/id_rsa ${HOME}/.ssh/*.id; do
        ssh-add ${f}
    done
fi
