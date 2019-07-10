# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

mkdir -p ${HOME}/.nodejs
npm set prefix ${HOME}/.nodejs
PATH=${HOME}/.nodejs/bin:${PATH}

