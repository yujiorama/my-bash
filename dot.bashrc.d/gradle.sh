# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

download_new_file "https://raw.githubusercontent.com/gradle/gradle-completion/master/gradle-completion.bash" "${HOME}/.gradle.bash"

source ${HOME}/.gradle.bash

export GRADLE_CACHE_TTL_MINUTES=$(expr 1440 \* 30)
