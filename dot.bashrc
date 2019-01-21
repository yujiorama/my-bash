if [[ ! -z "${ConEmuPID}" ]]; then
  /c/WINDOWS/system32/chcp.com 65001
fi

for f in $(find ${HOME}/.bashrc.d -type f -name \*sh); do
    source ${f} 2>error.log
    if [[ -s error.log ]]; then
    	echo "${f}: $(cat error.log)"
    fi
    rm -f error.log
done

echo "Startup Time: $SECONDS sec"
