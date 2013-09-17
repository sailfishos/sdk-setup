# mb.bash - bash completion for mb
#
# Copyright (C) 2013 Jolla Ltd.
# Contact: Juha Kallioinen <juha.kallioinen@jollamobile.com>
#
# Licensed under GPL version 2

_mb_comp()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="build clean"

    case "${prev}" in
	-t|--target)
	    local targets=$(sb2-config -l)
	    COMPREPLY=( $(compgen -W "${targets}" -- "${cur}") )
	    return 0
	    ;;
	build|-*)
	    COMPREPLY=( $(compgen -W "-t -d -v -j -h --target --enable-debug --verbose --jobs --help" -- "${cur}") )
	    return 0
	    ;;
	"$1")
	    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
	    return 0
	    ;;
    esac

    return 0
} &&
complete -F _mb_comp -o default mb
