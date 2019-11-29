# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

ip()
{
    local subcommand=$1
    case ${subcommand} in
        a)
            ipconfig | grep IPv4 | cut -d ':' -f 2 | sed -e 's/^ //'
        ;;
    esac
}

java_home() {
    echo "${JAVA_HOME}"
}

npm_exec() {
    PATH=$(npm bin):${PATH}
    echo "$*"
    eval "$*"
}
