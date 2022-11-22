#!/usr/bin/env python3

#This script allows for sounds in i3


import os
import i3ipc


# sound command dictionary
sounds = {'newWindow': 'play -n synth .25 sin 440:880 sin 480:920 remix - norm -3 pitch -500',
    'modeKey': 'play -qV0 "|sox -np synth .07 sq 400" "|sox -np synth .5 sq 800" fade h 0 .5 .5 norm -20',
    'modeDefaultKey': 'play -qV0 "|sox -np synth .07 sq 400" "|sox -np synth .5 sq 800" fade h 0 .5 .5 norm -20 reverse'}

def play_sound(event, sounds = sounds):
    os.system(sounds[event])



i3 = i3ipc.Connection()

i3.on('window::new', play_sound("newWindow"))

i3.main()
