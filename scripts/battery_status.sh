#!/usr/bin/env bash
if command -v acpi &> /dev/null ; then
    bat=$(acpi -b)
    spd-say -P important -Cw "$bat"
else
    find /sys/class/power_supply -type l -exec bash -c '
    for i ; do
        if [[ -e "$i/capacity" ]]; then
            bat="${i##*/}"
            bat="${bat//BAT/Battery }"
            bat="${bat}: $(cat "${i}/capacity") percent"
            spd-say -P important -Cw "$bat"
        fi
    done
' _ {} \;
fi
