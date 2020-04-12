#!/bin/bash

if [[ "${OS}" = "Linux" ]]; then
    return
fi

if ! command -v choco >/dev/null 2>&1; then
    if [[ ! -e "C:/ProgramData/chocoportable/bin/choco.exe" ]]; then
        sudo powershell -noprofile -noninetractive -command '$input | iex' \
            <<< "Install-PackageProvider Chocolatey -scope CurrentUser; Set-PackageSource -name Chocolatey -trusted"
    fi
fi

if [[ -e "C:/ProgramData/chocoportable/bin/choco.exe" ]]; then
    export PATH
    PATH=/c/ProgramData/chocoportable/bin:"${PATH}"
fi

if ! command -v choco >/dev/null 2>&1; then
    return
fi

if choco search --local-only vcredist140 | grep '0 package installed'; then
    sudo choco install --yes vcredist140
fi
