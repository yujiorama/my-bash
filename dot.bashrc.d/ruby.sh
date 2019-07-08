# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if ! which ruby >/dev/null 2>&1; then
    return
fi

urlencode() {
    local uri="$1"
    ruby -ruri -e "puts URI.parse('$uri').to_s"
}

urldecode() {
    local uri="$1"
    ruby -rcgi -e "puts CGI.unescape('$uri')"
}
