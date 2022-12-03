#!/bin/bash

# Add this to your crontab to have battery status automatically reported when it starts getting low
# */10 * * * * XDG_RUNTIME_DIR=/run/user/1000 /home/user/.config/i3/scripts/game_controler.sh

# Set the name to your battery here.
# If not set, it will be automatically detected.
batteryName=""

if [[ "$batteryName" == "" ]]; then
    batteryName="$(find /sys/class/power_supply -name 'sony_controller_battery_*' | cut -d/ -f5)"
fi

# If there's no file, we don't check it.
if [[ ! -f "/sys/class/power_supply/${batteryName}/capacity" ]]; then
    spd-say -P important -Cw "Battery not found."
    exit 0
fi

oldPercent="$(tail -1 "$0" | tr -cd '[:digit:]')"
oldPercent="${oldPercent:-0}"

percent=$(cat "/sys/class/power_supply/${batteryName}/capacity" | tr -cd '[:digit:]')
status="$(cat "/sys/class/power_supply/${batteryName}/status")"

# If status is requested, give it and exit.
if [[ "$1" == "-s" || "$1" == "--status" ]]; then
    spd-say -P important -Cw "Battery ${percent} percent, ${status,,}."
    exit 0
fi

if [[ $percent -ne $oldPercent && $percent -gt 10 ]]; then
    spd-say "Battery $(</sys/class/power_supply/${batteryName}/capacity) percent."
fi

if [[ $percent -le 10 ]]; then
    spd-say "Battery $(</sys/class/power_supply/${batteryName}/capacity) percent."
fi

if [[ "$status" == "Full" ]]; then
    spd-say "Battery $(</sys/class/power_supply/${batteryName}/capacity) percent, ${status,,}."
fi

# remove the last line of the file and update it with the new percentage.
lastLine="$(grep -n '^exit 0' $0)"
# Convert lastLine to a number andd increment it by 1.
lastLine=${lastLine%%:*}
lastLine=$((lastLine + 1))
sed -i "${lastLine}"',$d' $0
echo "$percent" >> "$0"

exit 0
50
