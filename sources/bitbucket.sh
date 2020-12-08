# shellcheck shell=bash

url="https://bitbucket.org/atlassianlabs/atlascode/raw/main/resources/schemas/pipelines-schema.json"
schema="${MY_BASH_APP}/atlassianlab-atlascode/pipelines-schema.json"
download_new_file "${url}" "${schema}"
unset url schema
