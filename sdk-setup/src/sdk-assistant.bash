# sdk-assistant.bash - bash completion for sdk-assitant
#
# Copyright (C) 2014 Jolla Ltd.
# Contact: Juha Kallioinen <juha.kallioinen@jolla.com>
# All rights reserved.
#
# You may use this file under the terms of BSD license as follows:
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#   * Neither the name of the Jolla Ltd nor the
#     names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# for the @(pattern-list) syntax to work
shopt -s extglob

_sdk_ass_comp()
{
    local cur prev special i
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ "$cur" != -* ]; then
	for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
	    if [[ ${COMP_WORDS[i]} == @(create|remove|list) ]]; then
		special=${COMP_WORDS[i]}
	    fi
	done
    fi

    if [ -n "$special" ]; then
	case $special in
	    create)
		COMPREPLY=( $(compgen -W "-a --arch -y --non-interactive" -- "${cur}") )
		case $prev in
		    -a|--arch)
			COMPREPLY=( $(compgen -W "arm i486" -- "${cur}") )
			return 0
			;;
		esac
		return 0
		;;
	    remove)
		local targets=$(sb2-config -f)
		COMPREPLY=( $(compgen -W "${targets} -y --non-interactive" -- "${cur}") )
		return 0
		;;
	    *)
		COMPREPLY=()
		return 0
		;;
	esac
    fi

    case $prev in
	-a|--arch)
	    COMPREPLY=( $(compgen -W "arm i486" -- "${cur}") )
	    return 0
	    ;;
    esac

    if [[ "$cur" == -* ]]; then
	COMPREPLY=( $( compgen -W '-a --arch -y -z --dry-run --non-interactive -h --help' -- "$cur" ) )
    else
	COMPREPLY=( $( compgen -W 'create remove list \
                                   -a --arch -y -z --dry-run --non-interactive -h --help' -- "$cur" ) )
    fi

    return 0;
} &&
complete -F _sdk_ass_comp -o default sdk-assistant
