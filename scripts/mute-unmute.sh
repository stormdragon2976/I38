#!/bin/bash
if [ $(pamixer --get-mute) = false ]; then
spd-say -Cw 'Muting!'
pamixer -t
else
pamixer -t
spd-say -Cw 'Unmuted!'
fi
