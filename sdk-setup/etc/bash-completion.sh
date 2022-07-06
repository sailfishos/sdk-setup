# If not bash or not running interactively, don't do anything
[ -z "$BASH" -o -z "$PS1" ] && return

if [ -d /etc/bash_completion.d ]; then
    for i in /etc/bash_completion.d/*; do
        . "$i"
    done
    unset i
fi
