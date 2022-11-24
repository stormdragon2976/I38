# I38

Accessibility setup script for the i3 window manager.


## Why the name?

An uppercase I looks like a 1, 3 from i3, and 8 because the song [We Are 138](https://www.youtube.com/watch?v=-n2Mkdw4q44) rocks!


## Requirements

- sgtk-menu: for applications menu
- grun: Run application dialog
- python-i3ipc: for sounds etc.
- sox: for sounds.
- transfersh: [optional] for file sharing GUI
- playerctl: music controls
- clipster: clipboard manager
- xclip: Clipboard support
- libnotify: For sending notifications
- notification-daemon: To handle notifications

I38 will try to detect your browser, file manager, and web browser and present you with a list of options to bind to their launch keys. It will also create bindings for pidgin and mumble if they are installed. To use the bindings, press your ratpoison mode key which is set when you run the i38.sh script. next, press the binding for the application you want, w for web browser, e for text editor, f for file manager, m for mumble, etc. To learn all the bindings, find and read the mode ratpoison section of ~/.config/i3/config.
