#!/usr/bin/env python3
# Written by Storm Dragon, Jeremiah, and contributers.
# Released under the terms of the WTFPL http://www.wtfpl.net

import i3ipc
from i3ipc import Event
from os import system
#This script allows for sounds in i3
i3 = i3ipc.Connection()


def on_new_window(self,i3):
    system('play -n synth .25 sin 440:880 sin 480:920 remix - norm -3 pitch -500 &')

def on_mode(self,event):
    mode= event.change
    if mode == 'default':
        system('play -qV0 "|sox -np synth .07 sq 400" "|sox -np synth .5 sq 800" fade h 0 .5 .5 norm -20 reverse &')
    else:
            system('play -qV0 "|sox -np synth .07 sq 400" "|sox -np synth .5 sq 800" fade h 0 .5 .5 norm -20 &')

def on_workspace_focus(self,i3):
    #system('play -qnV0 synth pi fade 0 .25 .15 pad 0 1 reverb overdrive riaa norm -8 speed 1 &')
    pass

def on_workspace_move(self,i3):
    system('play -qnV0 synth pi fade 0 .25 .15 pad 0 1 reverb riaa norm -8 speed 1 reverse &')

def on_restart(self,i3):
    system('play -qn synth .25 saw 500:1200 fade .1 .25 .1 norm -8 &')

def on_exit(self,i3):
    system('play -qn synth .3 sin 700:200 fade 0 .3 0 &')

def on_fullscreen(self,i3):
    system('play -qn synth br flanger fade h .3 .3 0 &')

i3 = i3ipc.Connection()

i3.on('window::new', on_new_window)
i3.on(Event.MODE, on_mode)
i3.on('workspace::focus', on_workspace_focus)
i3.on('window::move', on_workspace_move)
i3.on('window::fullscreen_mode', on_fullscreen)
i3.on('shutdown::restart', on_restart)
i3.on('shutdown::exit', on_exit)
i3.main()
