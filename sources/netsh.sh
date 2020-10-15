# shellcheck shell=bash

if [[ "${OS}" = "Linux" ]]; then
    return
fi

cat - <<'EOS' > "${MY_BASH_COMPLETION}/netsh"
function __netsh_command_completion {

    local candidates_
    candidates_=$(netsh help | iconv -f SJIS -t UTF-8 | awk '{if($2 == "-"){print $1}}' | tr '\n' ' ')
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${candidates_}" -- "${COMP_WORDS[COMP_CWORD]}") )
    elif [[ $COMP_CWORD -eq 2 ]]; then
        case "${COMP_WORDS[COMP_CWORD-1]}" in
            "interface")
                candidates_=$(netsh interface help | iconv -f SJIS -t UTF-8 | awk '{if($2 == "-"){print $1}}' | tr '\n' ' ')
                COMPREPLY=( $(compgen -W "${candidates_}" -- "${COMP_WORDS[COMP_CWORD]}") )
            ;;
            *)
            :
            ;;
        esac
        :
    elif [[ $COMP_CWORD -eq 3 ]]; then
        case "${COMP_WORDS[COMP_CWORD-2]}" in
            "interface")
                case "${COMP_WORDS[COMP_CWORD-1]}" in
                    "portproxy")
                        candidates_=$(netsh interface portproxy help | iconv -f SJIS -t UTF-8 | awk '{if($2 == "-"){print $1}}' | tr '\n' ' ')
                        COMPREPLY=( $(compgen -W "${candidates_}" -- "${COMP_WORDS[COMP_CWORD]}") )
                    ;;
                    *)
                    ;;
                esac
            ;;
            *)
            :
            ;;
        esac
        :
    fi
}

complete -o default -o nospace -F __netsh_command_completion netsh
EOS
