# shellcheck shell=bash

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

function awscli-ssm-plugin-install {

    if [[ "${OS}" = "Linux" ]]; then
        return
    fi

    if [[ "${OS}" != "Linux" ]]; then

        if [[ ! -d "${AWSCLI_SSMPLUGIN_INSTALLER}" ]]; then
            mkdir -p "${AWSCLI_SSMPLUGIN_INSTALLER}"
        fi

        local url
        url='https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe'

        local install_file
        install_file=$(download_new_file "${url}" "${AWSCLI_SSMPLUGIN_INSTALLER}/$(basename "${url}")")
        if [[ ! -e "${install_file}" ]]; then
            return
        fi

        "${install_file}"

        rm -f "${install_file}"
    fi

    # shellcheck disable=SC1091
    [[ -e "${MY_BASH_SOURCES}/aws.env" ]] && source "${MY_BASH_SOURCES}/aws.env"
    # shellcheck disable=SC1091
    [[ -e "${MY_BASH_SOURCES}/aws.sh" ]] && source "${MY_BASH_SOURCES}/aws.sh"

    command -v session-manager-plugin
}

function aws-s3-bucket-delete() {
    local bucket
    bucket="$1"
    if [[ -z "${bucket}" ]]; then
        return 1
    fi
    if ! command -v aws >/dev/null 2>&1; then
        return 1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        return 1
    fi

    if ! aws s3api put-bucket-versioning --bucket "${bucket}" --versioning-configuration Status=Suspended; then
        return 1
    fi

    local delete_json
    delete_json=$(basename "$(mktemp -p "${PWD}")")
    aws s3api list-objects --bucket "${bucket}" | jq -r '{"Objects": [.Contents[] | {"Key": .Key}], "Quiet": false }' > "${delete_json}"
    if [[ ! -s "${delete_json}" ]]; then
        rm -f "${delete_json}"
        return 1
    fi

    (
        trap "rm -v ${delete_json}" 0 1 2 3 15
        aws s3api delete-objects --bucket "${bucket}" --delete "file://${delete_json}"
        aws s3api delete-bucket --bucket "${bucket}"
    ) | cat -

    return 0
}

function aws-ecr-repository-delete() {
    local repository
    repository="$1"
    if [[ -z "${repository}" ]]; then
        return 1
    fi
    if ! command -v aws >/dev/null 2>&1; then
        return 1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        return 1
    fi
    local images
    images=$(aws ecr list-images --repository-name "${repository}" --query 'imageIds[].imageTag' --output json | jq -r 'map("imageTag=" + .) | join(" ")')
    if [[ -z "${images}" ]]; then
        return 1
    fi

    # shellcheck disable=SC2086
    if ! aws ecr batch-delete-image --repository "${repository}" --image-ids ${images}; then
        return 1
    fi

    aws ecr delete-repository --repository "${repository}"
    return 0
}


if [[ "${HOME}/scoop/shims/aws" = "$(command -v aws)" ]]; then
    if [[ -e "${HOME}/scoop/apps/aws/current/aws_completer.exe" ]]; then
        echo "complete -C ${HOME}/scoop/apps/aws/current/aws_completer.exe aws" > "${MY_BASH_COMPLETION}/awscli"
    fi
elif command -v aws_completer >/dev/null 2>&1; then
    echo "complete -C aws_completer aws" > "${MY_BASH_COMPLETION}/awscli"
else
    :
fi

url="https://d33vqc0rt9ld30.cloudfront.net/latest/gzip/CloudFormationResourceSpecification.json"
schema="${MY_BASH_APP}/cloud-formation/schema.json"
download_new_file "${url}" "${schema}"
unset url schema
