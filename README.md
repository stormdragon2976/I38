# I38

Accessibility setup script for the i3 window manager.

## i38.sh
Released under the terms of the WTFPL License: http://www.wtfpl.net
This is a Stormux project: https://stormux.org

## Why the name?

An uppercase I looks like a 1, 3 from i3, and 8 because the song [We Are 138](https://www.youtube.com/watch?v=-n2Mkdw4q44) rocks!


## Requirements

- acpi: [optional] for battery status. It will still work even without this package, but uses it if it is installed.
- clipster: clipboard manager
- grun: Run application dialog
- jq: for getting the current workspace
- libnotify: For sending notifications
- notification-daemon: To handle notifications
- ocrdesktop: For getting contents of the current window with OCR.
- pamixer: for the mute-unmute script
- playerctl: music controls
- python-i3ipc: for sounds etc.
- sgtk-menu: for applications menu
- sox: for sounds.
- transfersh: [optional] for file sharing GUI
- xclip: Clipboard support
- yad: For screen reader accessible dialogs

I38 will try to detect your browser, file manager, and web browser and present you with a list of options to bind to their launch keys. It will also create bindings for pidgin and mumble if they are installed. To use the bindings, press your ratpoison mode key which is set when you run the i38.sh script. next, press the binding for the application you want, w for web browser, e for text editor, f for file manager, m for mumble, etc. To learn all the bindings, find and read the mode ratpoison section of ~/.config/i3/config.

## Usage:

- With no arguments, create the i3 configuration.
- -h: This help screen.
- -u: Copy over the latest version of scripts.
- -x: Generate ~/.xinitrc and ~/.xprofile.
- -X: Generate ~/.xprofile only.
