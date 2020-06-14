#!/bin/bash
# skip: no

if [[ "${OS}" == "Linux" ]]; then
    sudo cgroupfs-mount
fi

if [[ "${OS}" != "Linux" ]]; then

    function wsl-shutdown {
        wsl --shutdown

        local wsl_debian_root
        wsl_debian_root="$(find "$(cygpath -ma "${LOCALAPPDATA}/Packages")" -type d -name 'TheDebianProject*' | head -n 1)"
        if [[ ! -d "${wsl_debian_root}" ]]; then
            return
        fi

        local vhdx
        vhdx="$(find "${wsl_debian_root}/LocalState" -type f -name ext4.vhdx)"
        if [[ ! -e "${vhdx}" ]]; then
            return
        fi

        local ps1_file
        ps1_file="$(mktemp --suffix=.ps1 --tmpdir="${TMP}")"

        cat - <<-'EOS' > "${ps1_file}"
Param(
    [string]$vhdxPath = "ext4.vhdx"
)
Optimize-Vhd -Path $vhdxPath -Mode full
EOS

        powershell -file "${ps1_file}" -vhdxPath "${vhdx}"
        rm -f "${ps1_file}"

        return 0
    }
fi
