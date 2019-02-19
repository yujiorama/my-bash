# ex: ts=4 sw=4 et filetype=sh

__scoop_command_completion()
{
	local candidates_
    compword_="${COMP_WORDS[${COMP_CWORD}]}"
    candidates_=$(scoop help | sed -r -e '/^$/d' -e '/.*(Usage|Some useful|to get help).*/d' | awk '{print $1}' | tr '\n' ' ')
    COMPREPLY=($(compgen -W "${candidates_}" -- "${compword_}"))
}

complete -o default -o nospace -F __scoop_command_completion scoop
