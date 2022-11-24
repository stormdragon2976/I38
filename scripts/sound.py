#!/usr/bin/env python3
import i3ipc
from i3ipc import Event
from os import system
#This script allows for sounds in i3
i3 = i3ipc.Connection()


def on_new_window(self,i3):
    system('play -n synth .25 sin 440:880 sin 480:920 remix - norm -3 pitch -500')

def on_mode(self,event):
    mode= event.change
    if mode == 'ratpoison':
            system('play -qV0 "|sox -np synth .07 sq 400" "|sox -np synth .5 sq 800" fade h 0 .5 .5 norm -20')
    elif mode == 'default':
        system('play -qV0 "|sox -np synth .07 sq 400" "|sox -np synth .5 sq 800" fade h 0 .5 .5 norm -20 reverse')

def on_workspace_focus(self,i3):
    system('play -qnV0 synth pi fade 0 .25 .15 pad 0 1 reverb overdrive riaa norm -8 speed 1')

def on_workspace_move(self,i3):
    system('play -qnV0 synth pi fade 0 .25 .15 pad 0 1 reverb overdrive riaa norm -8 speed 1 reverse')

i3 = i3ipc.Connection()

i3.on('window::new', on_new_window)
i3.on(Event.MODE, on_mode)
# get current mode:
# var = i3ipc.ModeEvent(data)
i3.on('workspace::focus', on_workspace_focus)
i3.on('window::move', on_workspace_move)
i3.main()
