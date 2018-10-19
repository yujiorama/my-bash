for f in $(find ${HOME}/.bashrc.d -type f -name \*.sh); do
    source ${f}
done

if [[ ! -z "${ConEmuPID}" ]]; then
  /c/WINDOWS/system32/chcp.com 65001
fi
