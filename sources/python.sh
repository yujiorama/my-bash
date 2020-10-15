# shellcheck shell=bash

if ! command -v "${PYTHON}" >/dev/null 2>&1; then
	return
fi

for pkg in see httpie git-filter-repo; do
    ${PYTHON} -m pip install --user --progress-bar off --no-color --timeout 3 ${pkg} >/dev/null 2>&1 &
done
wait

# if command -v aws_completer >/dev/null 2>&1; then
#     echo "complete -C aws_completer aws" > "${MY_BASH_COMPLETION}/awscli"
# fi
