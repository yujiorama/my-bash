if [[ ! -z "${ConEmuPID}" ]]; then
  /c/WINDOWS/system32/chcp.com 65001
fi

[[ -e ${HOME}/.bashrc.d/.function ]] && source ${HOME}/.bashrc.d/.function

for f in $(find ${HOME}/.bashrc.d -type f -name \*sh); do
	starttime=$SECONDS
    source ${f} 2>error.log
    if [[ -s error.log ]]; then
    	echo "${f}: $(cat error.log)"
    fi
    rm -f error.log
    laptime=$(( SECONDS - starttime ))
    echo "${f}: $laptime sec"
done

echo "Startup Time: $SECONDS sec"
