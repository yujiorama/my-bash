#!/bin/bash
completion="${MY_BASH_COMPLETION}/gradle"
url=https://raw.githubusercontent.com/gradle/gradle-completion/master/gradle-completion.bash

download_new_file "${url}" "${completion}"

unset completion url
