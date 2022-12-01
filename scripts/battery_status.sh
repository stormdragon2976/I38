#!/usr/bin/env bash

#check for acpi
if command -v acpi &> /dev/null; then
    bat="$(acpi -b)"
    spd-say -P important -Cw "$bat"
else
    find /sys/class/power_supply -type l -exec bash -c '
        for i ; do
            if [[ -e "$i/capacity" ]]; then
                bat="${i##*/}"
                bat="${bat//BAT/Battery }"
                bat="${bat}: $( { cat "${i}/status";echo -n ", "; cat "${i}/capacity"; } | tr -d \\n) percent."
                spd-say -P important -Cw "$bat"
            fi
        done
    ' _ {} \;
fi
