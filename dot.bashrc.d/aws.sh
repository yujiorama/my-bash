#!/bin/bash
ecs-cli-download() {
    local ecs_cli_ext ecs_cli_domain ecs_cli_executable_url ecs_cli_checksum_url

    ecs_cli_ext=".exe"
    ecs_cli_domain="amazon-ecs-cli.s3.amazonaws.com:443"

    if ! online "${ecs_cli_domain}"; then
        return
    fi

    ecs_cli_executable_url="https://${ecs_cli_domain}"
    ecs_cli_checksum_url="https://${ecs_cli_domain}"
    if [[ "${OS}" = "Windows_NT" ]]; then
        ecs_cli_executable_url="${ecs_cli_executable_url}/ecs-cli-windows-amd64-latest.exe"
        ecs_cli_checksum_url="${ecs_cli_checksum_url}/ecs-cli-windows-amd64-latest.md5"
    elif [[ -x "/bin/uname" ]] && [[ "$(uname)" = "Linux" ]]; then
        ecs_cli_ext=""
        ecs_cli_executable_url="${ecs_cli_executable_url}/ecs-cli-linux-amd64-latest"
        ecs_cli_checksum_url="${ecs_cli_checksum_url}/ecs-cli-linux-amd64-latest.md5"
    else
        return
    fi

    download_new_file "${ecs_cli_checksum_url}" "${HOME}/bin/ecs-cli${ecs_cli_ext}.md5"
    if [[ ! -e "${HOME}/bin/ecs-cli${ecs_cli_ext}.md5" ]]; then
        return
    fi

    download_new_file "${ecs_cli_executable_url}" "${HOME}/bin/ecs-cli${ecs_cli_ext}"
    if [[ -e "${HOME}/bin/ecs-cli${ecs_cli_ext}" ]]; then
        if ! echo -n "$(cat "${HOME}"/bin/ecs-cli${ecs_cli_ext}.md5) ${HOME}/bin/ecs-cli${ecs_cli_ext}" | md5sum -c --quiet; then
            rm -f "${HOME}/bin/ecs-cli${ecs_cli_ext}" "${HOME}/bin/ecs-cli${ecs_cli_ext}.md5"
        else
            "${HOME}/bin/ecs-cli${ecs_cli_ext}" --version
        fi
    fi
}

ecs-cli-download
