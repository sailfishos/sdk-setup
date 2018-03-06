# mb2.bash - bash completion for mb2
#
# Copyright (C) 2013-2018 Jolla Ltd.
# Contact: Martin Kampas <martin.kampas@jolla.com>
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

_mb2_comp()
{
    local cur prev special i
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ "$cur" != -* ]; then
	for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
	    if [[ ${COMP_WORDS[i]} == @(prep|build|qmake|make|deploy|run|ssh|install|installdeps|rpm|apply) ]]; then
		special=${COMP_WORDS[i]}
	    fi
	done
    fi

    if [ -n "$special" ]; then
	case $special in
	    build)
		COMPREPLY=( $(compgen -W "-d --enable-debug -p --doprep -j" -- "${cur}") )
		return 0
		;;
	    deploy)
		COMPREPLY=( $(compgen -W "--rsync --zypper --pkcon --sdk" -- "${cur}") )
		return 0
		;;
	    apply)
		COMPREPLY=( $(compgen -W "-R" -- "${cur}") )
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
	-p|--projectdir|-s|--specfile|-f|--shared-folder|-m|--submodule)
	    COMPREPLY=()
	    return 0
	    ;;
	-d|--device)
	    # TODO: can the available devices be autocompleted here?
	    COMPREPLY=()
	    return 0
	    ;;
    esac

    COMPREPLY=( $( compgen -W 'prep build qmake make deploy run ssh install installdeps rpm apply \
                           -d -p -s -t -i -f -x -X -c{,=} -m \
                           --shared-folder --target --device --increment --projectdir --specfile \
                           --fix-version{,=} --no-fix-version --git-change-log{,=} --submodule' -- "$cur" ) )

    return 0;
} &&
complete -F _mb2_comp -o default mb2
