# sdk-assistant.bash - bash completion for sdk-assitant
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

_sdk_assistant_comp()
{
    local cur=$2 prev=$3
    COMPREPLY=()

    _sdk_assistant_comp_next_positional()
    {
        local i=$1
        local _name=$2

        for ((; i<${#COMP_WORDS[@]}; i++)); do
            if [[ ${COMP_WORDS[i]} != -* ]]; then
                eval $_name=\${COMP_WORDS[i]}
                eval ${_name}_pos=\$i
                break
            fi
        done
    }
    trap 'trap - RETURN; unset _sdk_assistant_comp_next_positional' RETURN

    local i=1

    local type= type_pos=0
    _sdk_assistant_comp_next_positional $i type
    if [[ $type == @(tooling|target) ]]; then
        let i=type_pos+1
    else
        let i=type_pos
        type=
        type_pos=0
    fi

    local command= command_pos=0
    _sdk_assistant_comp_next_positional $i command
    if [[ $command == @(create|remove|list) ]]; then
        let i=command_pos+1
    else
        let i=command_pos
        command=
        command_pos=0
    fi

    local garbage= garbage_pos=0
    _sdk_assistant_comp_next_positional $i garbage

    if [[ ! $type ]]; then
        if [[ ! $command && (! $garbage || $COMP_CWORD -le $garbage_pos) ]]; then
            COMPREPLY=( $(compgen -W "tooling target create remove list -h --help" -- "$cur") )
            return 0
        elif [[ $COMP_CWORD -lt $command_pos || ! $cur && $COMP_CWORD -eq $command_pos ]]; then
            COMPREPLY=( $(compgen -W "tooling target -h --help" -- "$cur") )
            return 0
        fi
    elif [[ $COMP_CWORD -lt $type_pos || ! $cur && $COMP_CWORD -eq $type_pos ]]; then
        COMPREPLY=( $(compgen -W "-h --help" -- "$cur") )
        return 0
    fi

    if [[ ! $command ]]; then
        if [[ ! $garbage || $COMP_CWORD -le $garbage_pos ]]; then
            COMPREPLY=( $(compgen -W "create remove list -h --help" -- "$cur") )
            return 0
        else
            COMPREPLY=( $(compgen -W "-h --help" -- "$cur") )
            return 0
        fi
    elif [[ $COMP_CWORD -lt $command_pos || ! $cur && $COMP_CWORD -eq $command_pos ]]; then
        COMPREPLY=( $(compgen -W "-h --help" -- "$cur") )
        return 0
    fi

    case $command in
        create)
            local name= name_pos=
            _sdk_assistant_comp_next_positional $((command_pos+1)) name
            local url= url_pos=
            _sdk_assistant_comp_next_positional $((name_pos+1)) url
            local garbage= garbage_pos=
            _sdk_assistant_comp_next_positional $((url_pos+1)) garbage

            if [[ $name && $COMP_CWORD -gt $name_pos && (! $url || $cur && $COMP_CWORD -eq $url_pos) && ! $garbage ]]; then
                COMPREPLY=( $(compgen -W "-y --non-interactive -z --dry-run -h --help" -A file -- "$cur") )
            else
                COMPREPLY=( $(compgen -W "-y --non-interactive -z --dry-run -h --help" -- "$cur") )
            fi
            ;;

        remove)
            local name= name_pos=
            _sdk_assistant_comp_next_positional $((command_pos+1)) name
            local garbage= garbage_pos=
            _sdk_assistant_comp_next_positional $((name_pos+1)) garbage

            if [[ ( ! $name || $cur && $COMP_CWORD -eq $name_pos ) && ! $garbage ]]; then
                local known_names=
                if [[ ! $type ]]; then
                    known_names=$(sdk-assistant tooling list; sdk-assistant target list)
                else
                    known_names=$(sdk-assistant $type list)
                fi
                COMPREPLY=( $(compgen -W "$known_names -y --non-interactive -z --dry-run -h --help" -- "$cur") )
            else
                COMPREPLY=( $(compgen -W "-y --non-interactive -z --dry-run -h --help" -- "$cur") )
            fi
            ;;

        list)
            COMPREPLY=( $(compgen -W "-h --help" -- "$cur") )
            ;;
    esac

    return 0;
} &&
complete -F _sdk_assistant_comp sdk-assistant
