#!/usr/bin/env python3
import i3ipc
from os import system
#This script allows for sounds in i3



def on_new_window(self,i3):
    system('play -n synth .25 sin 440:880 sin 480:920 remix - norm -3 pitch -500')

def on_mode(self,i3):
#    mode = i3ipc.ModeEvent(['change'])
#    if mode == 'resize':
            system('play -qV0 "|sox -np synth .07 sq 400" "|sox -np synth .5 sq 800" fade h 0 .5 .5 norm -20')
#    elif mode == 'default':
#        system('play -qV0 "|sox -np synth .07 sq 400" "|sox -np synth .5 sq 800" fade h 0 .5 .5 norm -20 reverse')

i3 = i3ipc.Connection()

i3.on('window::new', on_new_window)
i3.on('mode', on_mode)
# get current mode:
# var = i3ipc.ModeEvent(data)

i3.main()
