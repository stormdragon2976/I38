#!/bin/bash
if [ $(pamixer --get-mute) = false ]; then
spd-say -P important -Cw 'Muting!'
pamixer -t
else
pamixer -t
spd-say -P important -Cw 'Unmuted!'
fi
