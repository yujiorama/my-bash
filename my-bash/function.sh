#!/bin/bash

if [[ "${OS}" != "Linux" ]]; then
    function ip {
        local subcommand=$1
        case ${subcommand} in
            a)
                ipconfig | grep IPv4 | cut -d ':' -f 2 | sed -e 's/^ //'
            ;;
        esac
    }
fi
