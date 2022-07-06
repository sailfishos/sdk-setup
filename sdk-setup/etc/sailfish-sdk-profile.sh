sudo oneshot

# Exported by sdk-chroot
[[ -d "$SAILFISH_SDK_CWD" ]] && cd "$SAILFISH_SDK_CWD"
unset SAILFISH_SDK_CWD

if [[ -e ~/.mersdk.profile ]]; then
    cat >&2 <<'END'
WARNING: Deprecated ~/.mersdk.profile found!
   Use the SAILFISH_SDK environment variable inside your
   regular ~/.bashrc and/or ~/.bash_profile to branch to
   your SDK-specific configuration bits.

   if [[ $SAILFISH_SDK ]]; then
       ...
   fi
END
    . ~/.mersdk.profile
fi

for mer_check_locale in LC_COLLATE LC_NUMERIC; do
    if [[ $(locale |sed -n "s/^$mer_check_locale=\"\(.*\)\"$/\1/p") != POSIX ]]; then
        echo "${BASH_SOURCE[0]}: Warning: It is not recommended to change $mer_check_locale from\
 the default value \"POSIX\". Check your shell profile."
    fi
done
unset mer_check_locale

(
    declare -p SDK_MOTD_OPTIONS &>/dev/null || SDK_MOTD_OPTIONS=(--daily --no-refresh)
    motd=$(sdk-motd ${SDK_MOTD_OPTIONS:+"${SDK_MOTD_OPTIONS[@]}"}) || exit
    if [[ $motd ]]; then
        printf '\nDid you know…?\n\n%s\n' "$motd"
    fi
)
