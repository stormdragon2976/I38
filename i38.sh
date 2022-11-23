#!/bin/bash

# Configures the i3 window manager to make it screen reader accessible
# Written by Storm Dragon
# Released under the terms of the WTFPL http://www.wtfpl.net

i3Path="${XDG_CONFIG_HOME:-$HOME/.config}/i3"
# Dialog accessibility
export DIALOGOPTS='--no-lines --visit-items'

# Check to make sure minimum requirements are installed.
for i in dialog grun sgtk-menu yad ; do
    if ! command -v "$i" &> /dev/null ; then
        missing+=("$i")
    fi
done
if [[ -n "${missing}" ]]; then
    echo "Please install the following packages and run this script again:"
    echo "${missing[*]}"
    exit 1
fi

menulist() {
    # Args: List of items for menu.
    # returns: selected tag
    local menuText="$1"
    shift
    local menuList
    for i in "${@}" ; do
        menuList+=("$i" "$i")
    done
    dialog --title "I38" \
        --backtitle "Use the arrow keys to find the option you want, and enter to select it." \
        --clear \
        --no-tags \
        --menu "$menuText" 0 0 0 ${menuList[@]} --stdout
    return $?
} 

# rangebox
# $1 text to show
# $2 minimum value
# $3 maximum value
# $4 Default value
rangebox() {
    dialog --title "I38" \
    --backtitle "Use the arrow keys to select a number, then press enter." \
    --rangebox "$1" -1 -1 $2 $3 $4 --stdout
}

yesno() {
    # Returns: Yes 0 or No 1
    # Args: Question to user.
    dialog --clear --title "I38" --yesno "$*" -1 -1 --stdout && return 0
} 

help() {
    echo "${0##*/}"
    echo "Released under the terms of the WTFPL License: http://www.wtfpl.net"
    echo -e "This is a Stormux project: https://stormux.org\n"
    echo -e "Usage:\n"
    echo "With no arguments, create the i3 configuration."
    for i in "${!command[@]}" ; do
        echo "-${i/:/ <parameter>}: ${command[${i}]}"
    done | sort
    exit 0
}

write_xinitrc()
{
if [[ -f "$HOME/.xinitrc" ]]; then
continue="$(yesno "This will overwrite your existing $HOME/.xinitrc file. Do you want to continue?")"
if [ "$continue" = "no" ]; then
exit 0
fi
fi
cat << 'EOF' > ~/.xinitrc
#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

dbus-launch
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

[ -f /etc/xprofile ] && . /etc/xprofile
[ -f ~/.xprofile ] && . ~/.xprofile

export DBUS_SESSION_BUS_PID
export DBUS_SESSION_BUS_ADDRESS

exec i3
EOF
if [[ -f "$HOME/.xprofile" ]]; then
continue="$(yesno "Would you like to add accessibility variables to your $HOME/.xprofile? Without these, accessibility will be limited or may not work at all. Do you want to continue?")"
if [ "$continue" = "no" ]; then
exit 0
fi
fi
cat << 'EOF' > ~/.xprofile
# Accessibility variables
export ACCESSIBILITY_ENABLED=1
export GTK_MODULES=gail:atk-bridge
export GNOME_ACCESSIBILITY=1
export QT_ACCESSIBILITY=1
export QT_LINUX_ACCESSIBILITY_ALWAYS_ON=1
EOF
}


# Array of command line arguments
declare -A command=(
    [h]="This help screen."
    [x]="Generate ~/.xinitrc and ~/.xprofile."
)

# Convert the keys of the associative array to a format usable by getopts
args="${!command[*]}"
args="${args//[[:space:]]/}"
while getopts "${args}" i ; do
    case "$i" in
        h) help;;
        x) write_xinitrc
    esac
done

# Configuration questions
escapeKey="$(menulist "Ratpoison mode key:" Control+t Control+z -Control+Escape Alt+Escape Control+Space Super_L Super_R)"
escapeKey="${escapeKey//Alt/Mod1}"
dex=1
if command -v dex &> /dev/null ; then
    export dex=$(yesno "Would you like to autostart applications with dex?")
fi
brlapi=1
if [[ $dex -eq 1 ]]; then
    brlapi=$(yesno "Do you want to use a braille display with Orca?")
fi

if [[ -d "${i3Path}" ]]; then
    yesno "This will replace your existing configuration at ${i3Path}. Do you want to continue?" || exit 0
fi


# Create the i3 configuration directory.
mkdir -p "${i3Path}"
# Move scripts into place
cp -rv scripts/ "${i3Path}/scripts" | dialog --backtitle "I38" --progressbox "Moving scripts into place and writing config..." -1 -1

cat << EOF > ${i3Path}/config
# Generated by I38 (${0##*/}) https://github.com/stormdragon2976/I38
# $(date '+%A, %B %d, %Y at %I:%M%p')


# i3 config file (v4)
#
# Please see https://i3wm.org/docs/userguide.html for a complete reference!
#
# This config file uses keycodes (bindsym) and was written for the QWERTY
# layout.
#
# To get a config file with the same key positions, but for your current
# layout, use the i3-config-wizard
#

# Font for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
font pango:monospace 8

# Run dialog
bindsym Mod1+F2 exec grun

# Clipboard manager
bindsym Mod1+Control+c exec clipster -s

# gtk bar
bindsym Mod1+Control+Delete exec --no-startup-id sgtk-bar

# Use pactl to adjust volume in PulseAudio.
set $refresh_i3status killall -SIGUSR1 i3status
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status

# start a terminal
bindsym Mod1+Return exec i3-sensible-terminal

# kill focused window
bindsym Mod1+F4 kill

# Applications menu
bindsym Mod1+F1 exec --no-startup-id sgtk-menu -f

# Desktop icons
bindsym Mod1+Control+d exec --no-startup-id yad --icons --compact --no-buttons --title="Desktop" --close-on-unfocus --read-dir=${HOME}/Desktop

# change focus
# alt+tab and shift tab
bindsym Mod1+Shift+Tab focus left
bindsym Mod1+Tab focus right

# enter fullscreen mode for the focused container
bindsym Mod1+BackSpace fullscreen toggle

# focus the parent container
bindsym Mod1+a focus parent

# focus the child container
#bindsym Mod1+d focus child

# move the currently focused window to the scratchpad
bindsym Mod1+Shift+minus move scratchpad

# Show the next scratchpad window or hide the focused scratchpad window.
# If there are multiple scratchpad windows, this command cycles through them.
bindsym Mod1+minus scratchpad show

# Define names for default workspaces for which we configure key bindings later on.
# We use variables to avoid repeating the names in multiple places.
set \$ws1 "1"
set \$ws2 "2"
set \$ws3 "3"
set \$ws4 "4"
set \$ws5 "5"
set \$ws6 "6"
set \$ws7 "7"
set \$ws8 "8"
set \$ws9 "9"
set \$ws10 "10"

# switch to workspace
bindsym Control+F1 workspace number \$ws1
bindsym Control+F2 workspace number \$ws2
bindsym Control+F3 workspace number \$ws3
bindsym Control+F4 workspace number \$ws4
bindsym Control+F5 workspace number \$ws5
bindsym Control+F6 workspace number \$ws6
bindsym Control+F7 workspace number \$ws7
bindsym Control+F8 workspace number \$ws8
bindsym Control+F9 workspace number \$ws9
bindsym Control+F10 workspace number \$ws10

# move focused container to workspace
bindsym Control+Shift+F1 move container to workspace number \$ws1
bindsym Control+Shift+F2 move container to workspace number \$ws2
bindsym Control+Shift+F3 move container to workspace number \$ws3
bindsym Control+Shift+F4 move container to workspace number \$ws4
bindsym Control+Shift+F5 move container to workspace number \$ws5
bindsym Control+Shift+F6 move container to workspace number \$ws6
bindsym Control+Shift+F7 move container to workspace number \$ws7
bindsym Control+Shift+F8 move container to workspace number \$ws8
bindsym Control+Shift+F9 move container to workspace number \$ws9
bindsym Control+Shift+F10 move container to workspace number \$ws10


bindsym $escapeKey mode "ratpoison"
mode "ratpoison" {
# reload the configuration file
bindsym Control+; reload, mode "default"
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym Control+: restart, mode "default"
# exit i3 (logs you out of your X session)
bindsym Control+q exec "yad --image "dialog-question" --title 'I38' --button=yes:0 --button=no:1 --text 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' && exit i3
bindsym Escape mode "default"
}


$(if [[ $dex -eq 0 ]]; then
    echo '# Start XDG autostart .desktop files using dex. See also'
    echo '# https://wiki.archlinux.org/index.php/XDG_Autostart'
    echo 'exec --no-startup-id dex --autostart --environment i3'
else
    echo '# Startup applications'
    echo 'exec clipster -d'
echo 'exec /usr/lib/notification-daemon-1.0/notification-daemon'
    echo 'exec orca'
    if [[ $brlapi -eq 0 ]]; then
        echo 'xbrlapi --quiet'
    fi
fi)
EOF
