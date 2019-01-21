unset GIT_LFS_PATH

if [[ -d "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows" ]]; then
    cygpath --unix "${LOCALAPPDATA}/Programs/Microsoft Git Credential Manager for Windows" >> ${HOME}/.bash_path_suffix
fi

export GIT_SSH
if which plink >/dev/null 2>&1; then
    GIT_SSH=plink
elif which ssh >/dev/null 2>&1; then
    GIT_SSH=ssh
else
    :
fi
