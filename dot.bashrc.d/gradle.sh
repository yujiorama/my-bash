#!/bin/bash
completion="${HOME}/bin/gradle.completion"
url=https://raw.githubusercontent.com/gradle/gradle-completion/master/gradle-completion.bash

download_new_file "${url}" "${completion}"
if [[ -e "${completion}" ]]; then
    # shellcheck source=/dev/null
    source "${completion}"
fi
unset completion url
