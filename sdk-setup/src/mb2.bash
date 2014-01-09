# mb2.bash - bash completion for mb2
#
# Copyright (C) 2013 Jolla Ltd.
# Contact: Juha Kallioinen <juha.kallioinen@jollamobile.com>
#
# Licensed under GPL version 2

# for the @(pattern-list) syntax to work
shopt -s extglob

_mb2_comp()
{
    local cur prev special i
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ "$cur" != -* ]; then
	for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
	    if [[ ${COMP_WORDS[i]} == @(build|qmake|make|rpm|run|deploy|install) ]]; then
		special=${COMP_WORDS[i]}
	    fi
	done
    fi

    if [ -n "$special" ]; then
	case $special in
	    build)
		COMPREPLY=( $(compgen -W "-d --enable-debug" -- "${cur}") )
		return 0
		;;
	    deploy)
		COMPREPLY=( $(compgen -W " --rsync --zypper" -- "${cur}") )
		return 0
		;;
	    *)
		COMPREPLY=()
		return 0
		;;
	esac
    fi

    case $prev in
	-t|--target)
	    local targets=$(sb2-config -l)
	    COMPREPLY=( $(compgen -W "${targets}" -- "${cur}") )
	    return 0
	    ;;
	-p|--projectdir|-s|--specfile)
	    COMPREPLY=()
	    return 0
	    ;;
	-d|--device)
	    # TODO: can the available devices be autocompleted here?
	    COMPREPLY=()
	    return 0
	    ;;
    esac

    if [[ "$cur" == -* ]]; then
	COMPREPLY=( $( compgen -W '-d -i -p -s -t --target --device --increment --projectdir --specfile' -- "$cur" ) )
    else
	COMPREPLY=( $( compgen -W 'build qmake make ssh install rpm deploy run \
                                   -d -p -s -t -i --device --increment --projectdir --specfile --target' -- "$cur" ) )
    fi

    return 0;
} &&
complete -F _mb2_comp -o default mb2
