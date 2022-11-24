#!/bin/bash
if [ $(pamixer --get-mute) = false ]; then
spd-say -Cw 'muting'
pamixer -t
else
pamixer -t
spd-say -Cw 'unmuted'
fi
