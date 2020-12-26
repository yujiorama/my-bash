# shellcheck shell=bash

function gibo {
    if ! command -v docker >/dev/null 2>&1; then
        exit 1
    fi
    docker run --rm simonwhitaker/gibo "$@"
}
function dockviz {
    if ! command -v docker >/dev/null 2>&1; then
        exit 1
    fi
    docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz "$@"
}
function sslyze {
    if ! command -v docker >/dev/null 2>&1; then
        exit 1
    fi
    docker run -it --rm --network host nablac0d3/sslyze "$@"
}
