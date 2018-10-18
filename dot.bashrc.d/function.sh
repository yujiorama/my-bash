myds() {
    local name=$1
    local next_url="https://registry.hub.docker.com/v2/repositories/${name}/tags/?page=1"
    while [[ $next_url != "null" ]]; do
        curl --silent --location ${next_url} > ${TMP:-/tmp}/page.json
        cat ${TMP:-/tmp}/page.json | jq -r '.results[]["name"]' | sort
        next_url=$(cat ${TMP:-/tmp}/page.json | jq -r .next | tr -d '\r')
    done
}
