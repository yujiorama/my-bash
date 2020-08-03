#!/bin/bash

function ecscli-install {
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
            chmod 755 "${HOME}/bin/ecs-cli${ecs_cli_ext}"
            "${HOME}/bin/ecs-cli${ecs_cli_ext}" --version
        fi
    fi
}

function awscli-install {

    if [[ "${OS}" = "Linux" ]]; then
        
        if ! command -v unzip >/dev/null 2>&1; then
            return
        fi

        local url
        url="https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip"

        local install_file
        install_file=$(download_new_file "${url}" "${AWSCLIV2_INSTALLER}/$(basename "${url}")")
        if [[ ! -e "${install_file}" ]]; then
            return
        fi

        unzip -q -d "${AWSCLIV2_INSTALLER}" "${install_file}"


        if [[ ! -e "${AWSCLIV2_INSTALLER}/aws/install" ]]; then
            return
        fi

        bash "${AWSCLIV2_INSTALLER}/aws/install" \
          --install-dir "${AWSCLIV2_INSTALLER}/aws-cli" \
          --bin-dir "${AWSCLIV2}" \
          --update
    fi

    if [[ "${OS}" != "Linux" ]]; then

        if ! command -v msiexec >/dev/null 2>&1; then
            return
        fi

        local url
        url="https://awscli.amazonaws.com/AWSCLIV2.msi"

        local install_file
        install_file=$(download_new_file "${url}" "${AWSCLIV2_INSTALLER}/$(basename "${url}")")
        if [[ ! -e "${install_file}" ]]; then
            return
        fi

        MSYS_NO_PATHCONV=1 msiexec /i "$(cygpath -wa "${install_file}")" AWSCLIV2="$(cygpath -wa "${AWSCLIV2}")" /qb
    fi

    command -v aws

    # shellcheck disable=SC1090
    source "${MY_BASH_SOURCES}/aws.sh"
}

function awscli-uninstall {

    if [[ ! -e "${AWSCLIV2_INSTALLER}" ]]; then
        return
    fi

    MSYS_NO_PATHCONV=1 msiexec /uninstall "$(cygpath -wa "${AWSCLIV2_INSTALLER}")" /qb
}


if command -v aws_completer >/dev/null 2>&1; then
    echo "complete -C aws_completer aws" > "${MY_BASH_COMPLETION}/awscli"
fi
