# vi: ai et ts=4 sw=4 sts=4 expandtab fs=shell

if ! command -v ruby >/dev/null 2>&1; then
    return
fi

case ${OS:-Linux} in
    Windows*)
        ruby_root_="$(dirname "$(command -v ruby)")"
        if [[ -e "${ruby_root_}/bundle.cmd" ]]; then
            alias be="${ruby_root_}/bundle.cmd exec "
            alias bundle="${ruby_root_}/bundle.cmd "
        fi
        unset ruby_root_
    ;;
    *)
      alias be='bundle exec '
    ;;
esac

urlencode() {
    local uri="$1"
    ruby -ruri -e "puts URI.parse('$uri').to_s"
}

urldecode() {
    local uri="$1"
    ruby -rcgi -e "puts CGI.unescape('$uri')"
}
