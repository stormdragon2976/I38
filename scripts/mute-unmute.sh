#!/bin/bash
if [ $(pamixer --get-mute) = false ]; then
spd-say -P important -Cw 'Muting!'
pamixer -t
else
pamixer -t
play -qnG synth 0.05 sin 440
spd-say -P important -Cw 'Unmuted!'
fi
