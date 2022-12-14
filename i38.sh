#!/bin/bash

# Configures the i3 window manager to make it screen reader accessible
# Written by Storm Dragon, Jeremiah, and contributers.
# Released under the terms of the WTFPL http://www.wtfpl.net

i3Path="${XDG_CONFIG_HOME:-$HOME/.config}/i3"
# Dialog accessibility
export DIALOGOPTS='--no-lines --visit-items'

# Check to make sure minimum requirements are installed.
for i in dialog grun jq sgtk-menu yad ; do
    if ! command -v "$i" &> /dev/null ; then
        missing+=("$i")
    fi
done
if ! python3 -c 'import i3ipc' &> /dev/null ; then
    missing+=("python-i3ipc")
fi
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
    dialog --clear --title "I38" --yesno "$*" -1 -1 --stdout
    echo $?
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
yesno "This will overwrite your existing $HOME/.xinitrc file. Do you want to continue?" || exit 0
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
chmod +x ~/.xinitrc
}

write_xprofile() {
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
export SAL_USE_VCLPLUGIN=gtk3
EOF
exit 0
}

update_scripts() {
    cp -rv scripts/ "${i3Path}/" | dialog --backtitle "I38" --progressbox "Updating scripts..." -1 -1
    exit 0
}


# Array of command line arguments
declare -A command=(
    [h]="This help screen."
    [u]="Copy over the latest version of scripts."
    [x]="Generate ~/.xinitrc and ~/.xprofile."
    [X]="Generate ~/.xprofile only."
)

# Convert the keys of the associative array to a format usable by getopts
args="${!command[*]}"
args="${args//[[:space:]]/}"
while getopts "${args}" i ; do
    case "$i" in
        h) help;;
        u) update_scripts;;
        x) write_xinitrc ;&
        X) write_xprofile ;;
    esac
done

# Configuration questions
export i3Mode=$(yesno "Would you like to use ratpoison mode? This behaves more like strychnine, with an escape key followed by keybindings.")
if [[ $i3Mode -eq 1 ]]; then
    mod="Mod4"
fi
# Prevent setting ratpoison mode key to the same as default mode key
while [[ "$escapeKey" == "$mod" ]]; do
    escapeKey="$(menulist "Ratpoison mode key:" Control+t Control+z Control+Escape Alt+Escape Control+Space Super)"
    escapeKey="${escapeKey//Alt/Mod1}"
    escapeKey="${escapeKey//Super/Mod4}"
    mod="$(menulist "I3 mod key, for top level bindings:" Alt Control Super)"
    mod="${mod//Alt/Mod1}"
    mod="${mod//Super/Mod4}"
    if [ "$escapeKey" == "$mod" ]; then
        dialog --title "I38" --msgbox "Ratpoison and mod key cannot be the same key." -1 -1
    fi
done
# Volume jump
volumeJump=$(rangebox "How much should pressing the volume keys change the volume?" 1 15 5)
# Web browser
unset programList
for i in brave chromium epiphany firefox google-chrome-stable midori seamonkey ; do
    if command -v ${i/#-/} &> /dev/null ; then
        if [ -n "$programList" ]; then
            programList="$programList $i"
        else
            programList="$i"
        fi
    fi
done
if [ "$programList" != "${programList// /}" ]; then
    webBrowser="$(menulist "Web browser:" $programList)"
else
    webBrowser="${programList/#-/}"
fi
webBrowser="$(command -v $webBrowser)"
# Text editor
unset programList
for i in geany gedit kate kwrite l3afpad leafpad libreoffice mousepad pluma ; do
if hash ${i/#-/} &> /dev/null ; then
if [ -n "$programList" ]; then
programList="$programList $i"
else
programList="$i"
fi
fi
done
if [ "$programList" != "${programList// /}" ]; then
textEditor="$(menulist "Text editor:" $programList)"
else
textEditor="${programList/#-/}"
fi
textEditor="$(command -v $textEditor)"
# File browser
# Configure file browser
unset programList
for i in caja nemo nautilus pcmanfm pcmanfm-qt thunar ; do
    if hash ${i/#-/} &> /dev/null ; then
        if [ -n "$programList" ]; then
            programList="$programList $i"
        else
            programList="$i"
        fi
    fi
done
if [ "$programList" != "${programList// /}" ]; then
    fileBrowser="$(menulist "File browser:" $programList)"
else
    fileBrowser="${programList/#-/}"
fi
fileBrowser="$(command -v $fileBrowser)"
# Auto start with dex
dex=1
if command -v dex &> /dev/null ; then
    export dex=$(yesno "Would you like to autostart applications with dex?")
fi
if [[ $dex -eq 0 ]]; then
    dex -t "${XDG_CONFIG_HOME:-${HOME}/.config}/autostart" -c $(command -v orca)
fi
brlapi=1
brlapi=$(yesno "Do you want to use a braille display with Orca?")
sounds=1
sounds=$(yesno "Do you want window event sounds?")
keep=1
keep=$(yesno "Do you want to use keep.sh to upload files?")
if [[ -d "${i3Path}" ]]; then
    yesno "This will replace your existing configuration at ${i3Path}. Do you want to continue?" || exit 0
fi


# Create the i3 configuration directory.
mkdir -p "${i3Path}"
# Move scripts into place
cp -rv scripts/ "${i3Path}/" | dialog --backtitle "I38" --progressbox "Moving scripts into place and writing config..." -1 -1

cat << EOF > ${i3Path}/config
# Generated by I38 (${0##*/}) https://github.com/stormdragon2976/I38
# $(date '+%A, %B %d, %Y at %I:%M%p')


# i3 config file (v4)
#
# Please see https://i3wm.org/docs/userguide.html for a complete reference!
#
# This config file uses keycodes (bindsym) and was written for the QWERTY
# layout.

# set mod key
set \$mod $mod

# set workspace layout to tabbed so apps use most of the screen
workspace_layout tabbed

# set the mouse so it is trapped in focused window
# this fixes some issues in some games that require focus and pause when focus is moved via mouse accidentally
focus_follows_mouse no

# Font for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
font pango:monospace 8

# Run dialog
bindsym \$mod+F2 exec grun

# Clipboard manager
bindsym \$mod+Control+c exec clipster -s

# gtk bar
bindsym \$mod+Control+Delete exec --no-startup-id sgtk-bar

# Use pactl to adjust volume in PulseAudio.
bindsym \$mod+XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +${volumeJump}% & play -qnG synth 0.03 sin 440
bindsym \$mod+XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -${volumeJump}% & play -qnG synth 0.03 sin 440
bindsym \$mod+XF86AudioMute exec --no-startup-id ${i3Path}/scripts/mute-unmute.sh

# Music player controls
# Requires playerctl.
bindsym XF86AudioRaiseVolume exec --no-startup-id ${i3Path}/scripts/music_controler.sh incvol $volumeJump
bindsym XF86AudioLowerVolume exec --no-startup-id ${i3Path}/scripts/music_controler.sh decvol $volumeJump
bindsym XF86AudioPrev exec --no-startup-id ${i3Path}/scripts/music_controler.sh prev
bindsym XF86AudioMute exec --no-startup-id ${i3Path}/scripts/music_controler.sh pause
bindsym XF86AudioPlay exec --no-startup-id ${i3Path}/scripts/music_controler.sh play
bindsym \$mod+XF86AudioPlay exec --no-startup-id ${i3Path}/scripts/music_controler.sh info
bindsym XF86AudioStop exec --no-startup-id ${i3Path}/scripts/music_controler.sh stop
bindsym XF86AudioNext exec --no-startup-id ${i3Path}/scripts/music_controler.sh next

# start a terminal
bindsym \$mod+Return exec i3-sensible-terminal

# kill focused window
bindsym \$mod+F4 kill

# Applications menu
bindsym \$mod+F1 exec --no-startup-id sgtk-menu -f

# Desktop icons
bindsym \$mod+Control+d exec --no-startup-id yad --icons --compact --no-buttons --title="Desktop" --close-on-unfocus --read-dir=${HOME}/Desktop

# change focus
# alt+tab and alt+shift+tab
bindsym Mod1+Shift+Tab focus left
bindsym Mod1+Tab focus right

# enter fullscreen mode for the focused container
bindsym \$mod+BackSpace fullscreen toggle


# move the currently focused window to the scratchpad
bindsym \$mod+Shift+minus move scratchpad

# Show the next scratchpad window or hide the focused scratchpad window.
# If there are multiple scratchpad windows, this command cycles through them.
bindsym \$mod+minus scratchpad show

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
bindsym Control+F1 workspace number \$ws1, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh
bindsym Control+F2 workspace number \$ws2, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh
bindsym Control+F3 workspace number \$ws3, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh
bindsym Control+F4 workspace number \$ws4, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh
bindsym Control+F5 workspace number \$ws5, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh
bindsym Control+F6 workspace number \$ws6, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh
bindsym Control+F7 workspace number \$ws7, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh
bindsym Control+F8 workspace number \$ws8, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh
bindsym Control+F9 workspace number \$ws9, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh
bindsym Control+F10 workspace number \$ws10, exec --no-startup-id ${i3Path}/scripts/announce_workspace.sh

# move focused container to workspace
bindsym Control+Shift+F1 move container to workspace number \$ws1, exec spd-say -P important -Cw "moved to workspace 1"
bindsym Control+Shift+F2 move container to workspace number \$ws2, exec spd-say -P important -Cw "moved to workspace 2"
bindsym Control+Shift+F3 move container to workspace number \$ws3, exec spd-say -P important -Cw "moved to workspace 3"
bindsym Control+Shift+F4 move container to workspace number \$ws4, exec spd-say -P important -Cw "moved to workspace 4"
bindsym Control+Shift+F5 move container to workspace number \$ws5, exec spd-say -P important -Cw "moved to workspace 5"
bindsym Control+Shift+F6 move container to workspace number \$ws6, exec spd-say -P important -Cw "moved to workspace 6"
bindsym Control+Shift+F7 move container to workspace number \$ws7, exec spd-say -P important -Cw "moved to workspace 7"
bindsym Control+Shift+F8 move container to workspace number \$ws8, exec spd-say -P important -Cw "moved to workspace 8"
bindsym Control+Shift+F9 move container to workspace number \$ws9, exec spd-say -P important -Cw "moved to workspace 9"
bindsym Control+Shift+F10 move container to workspace number \$ws10, exec spd-say -P important -Cw "moved to workspace 10"


EOF

# Create ratpoison mode if requested.
if [[ -n "${escapeKey}" ]]; then
    cat << EOF >> ${i3Path}/config
bindsym $escapeKey mode "ratpoison"
mode "ratpoison" {
# Text editor bound to e
bindsym e exec $textEditor, mode "default"
# File browser bound to f
bindsym f exec $fileBrowser, mode "default"
# Web browser bound to w
bindsym w exec $webBrowser, mode "default"
$(if command -v mumble &> /dev/null ; then
    echo "bindsym m exec $(command -v mumble), mode \"default\""
fi)
$(if command -v ocrdesktop &> /dev/null ; then
    echo "bindsym Print exec $(command -v ocrdesktop), mode \"default\""
fi)
$(if command -v pidgin &> /dev/null ; then
    echo "bindsym p exec $(command -v pidgin), mode \"default\""
fi)
$(if command -v transfersh &> /dev/null ; then
    echo 'bindsym t exec bash -c '"'"'fileName="$(yad --title "I38 Upload File" --file)" && url="$(transfersh "${fileName}" | tee >(yad --title "I38 - Uploading ${fileName##*/} ..." --progress --pulsate --auto-close))" && echo "${url#*saved at: }" | tee >(yad --title "I38 - Upload URL" --show-cursor --show-uri --button yad-close --sticky --text-info) >(xclip -selection clipboard)'"', mode \"default\""
fi)
$(if [[ $keep -eq 0 ]]; then
    echo "bindsym k exec --no-startup-id $(echo $i3Path)/scripts/keep-uploader.sh, mode \"default\""
fi)
#Keyboard based volume Controls with pulseaudio
bindsym Mod1+Shift+0 exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +${volumeJump}% & play -qnG synth 0.03 sin 440
bindsym Mod1+Shift+9 exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -${volumeJump}% & play -qnG synth 0.03 sin 440
# Music player controls
# Requires playerctl.
bindsym Mod1+Shift+equal exec --no-startup-id ${i3Path}/scripts/music_controler.sh incvol $volumeJump, mode "default"
bindsym Mod1+Shift+minus exec --no-startup-id ${i3Path}/scripts/music_controler.sh decvol $volumeJump, mode "default"
bindsym Mod1+Shift+z exec --no-startup-id ${i3Path}/scripts/music_controler.sh prev, mode "default"
bindsym Mod1+Shift+c exec --no-startup-id ${i3Path}/scripts/music_controler.sh pause, mode "default"
bindsym Mod1+Shift+x exec --no-startup-id ${i3Path}/scripts/music_controler.sh play, mode "default"
bindsym Mod1+Shift+v exec --no-startup-id ${i3Path}/scripts/music_controler.sh stop, mode "default"
bindsym Mod1+Shift+b exec --no-startup-id ${i3Path}/scripts/music_controler.sh next, mode "default"
bindsym Mod1+Shift+u exec --no-startup-id ${i3Path}/scripts/music_controler.sh info, mode "default"
#Check battery status
bindsym Mod1+b exec --no-startup-id ${i3Path}/scripts/battery_status.sh, mode "default"
#Check controller battery status
bindsym g exec ${i3Path}/scripts/game_controler.sh -s, mode "default"
# Get a list of windows in the current workspace
bindsym apostrophe exec --no-startup-id ${i3Path}/scripts/window_list.sh, mode "default"
# Restart orca
bindsym Shift+o exec $(command -v orca) --replace, mode "default"
# reload the configuration file
bindsym Control+semicolon exec bash -c 'i3-msg -t run_command reload && spd-say -P important -Cw "I38 Configuration reloaded."', mode "default"
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym Control+Shift+semicolon exec bash -c 'i3-msg -t run_command restart && spd-say -P important -Cw "I3 restarted."', mode "default"
# exit i3 (logs you out of your X session)
bindsym Control+q exec bash -c 'yad --image "dialog-question" --title "I38" --button=yes:0 --button=no:1 --text "You pressed the exit shortcut. Do you really want to exit i3? This will end your X session." && i3-msg -t run_command exit'
bindsym Escape mode "default"
}


EOF
fi

# For those who do not want ratpoison mode.
if [[ -z "${escapeKey}" ]]; then
    cat << EOF >> ${i3Path}/config
# Text editor bound to $mod+e
bindsym \$mod+e exec $textEditor
# File browser bound to $mod+f
bindsym \$mod+f exec $fileBrowser
# Web browser bound to $mod+w
bindsym \$mod+w exec $webBrowser

$(if command -v mumble &> /dev/null ; then
    echo "bindsym \$mod+m exec $(command -v mumble)"
fi)
$(if command -v ocrdesktop &> /dev/null ; then
    echo "bindsym Print exec $(command -v ocrdesktop)"
fi)
$(if command -v pidgin &> /dev/null ; then
    echo "bindsym \$mod+p exec $(command -v pidgin)"
fi)
$(if command -v transfersh &> /dev/null ; then
    echo 'bindsym \$mod+t exec bash -c '"'"'fileName="$(yad --title "I38 Upload File" --file)" && url="$(transfersh "${fileName}" | tee >(yad --title "I38 - Uploading ${fileName##*/} ..." --progress --pulsate --auto-close))" && echo "${url#*saved at: }" | tee >(yad --title "I38 - Upload URL" --show-cursor --show-uri --button yad-close --sticky --text-info) >(xclip -selection clipboard)'"'"
fi)
$(if [[ $keep -eq 0 ]]; then
    echo "bindsym \$mod+k exec --no-startup-id $(echo $i3Path)/scripts/keep-uploader.sh"
fi)
#Keyboard based volume controls using pulseaudio
bindsym \$mod+Shift+0 exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +${volumeJump}% & play -qnG synth 0.03 sin 440
bindsym \$mod+Shift+9 exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -${volumeJump}% & play -qnG synth 0.03 sin 440
# Music player controls
# Requires playerctl.
bindsym \$mod+Shift+equal exec --no-startup-id ${i3Path}/scripts/music_controler.sh incvol $volumeJump
bindsym \$mod+Shift+minus exec --no-startup-id ${i3Path}/scripts/music_controler.sh decvol $volumeJump
bindsym \$mod+Shift+z exec --no-startup-id ${i3Path}/scripts/music_controler.sh prev
bindsym \$mod+Shift+c exec --no-startup-id ${i3Path}/scripts/music_controler.sh pause
bindsym \$mod+Shift+x exec --no-startup-id ${i3Path}/scripts/music_controler.sh play
bindsym \$mod+Shift+v exec --no-startup-id ${i3Path}/scripts/music_controler.sh stop
bindsym \$mod+Shift+b exec --no-startup-id ${i3Path}/scripts/music_controler.sh next
bindsym \$mod+Shift+u exec --no-startup-id ${i3Path}/scripts/music_controler.sh info
#Check battery status
bindsym \$mod+b exec --no-startup-id ${i3Path}/scripts/battery_status.sh
#Check controller battery status
bindsym \$mod+g exec ${i3Path}/scripts/game_controler.sh -s
# Get a list of windows in the current workspace
bindsym \$mod+apostrophe exec --no-startup-id ${i3Path}/scripts/window_list.sh
# Restart orca
bindsym \$mod+Shift+o exec $(command -v orca) --replace
# reload the configuration file
bindsym \$mod+Control+semicolon exec bash -c 'i3-msg -t run_command reload && spd-say -P important -Cw "I38 Configuration reloaded."'
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym \$mod+Control+Shift+semicolon exec bash -c 'i3-msg -t run_command restart && spd-say -P important -Cw "I3 restarted."'
# exit i3 (logs you out of your X session)
bindsym \$mod+Control+q exec bash -c 'yad --image "dialog-question" --title "I38" --button=yes:0 --button=no:1 --text "You pressed the exit shortcut. Do you really want to exit i3? This will end your X session." && i3-msg -t run_command exit'



EOF
fi

cat << EOF >> ${i3Path}/config
# Auto start section
$(if [[ $sounds -eq 0 ]]; then
    echo "exec_always --no-startup-id ${i3Path}/scripts/sound.py"
fi
if [[ $brlapi -eq 0 ]]; then
    echo 'exec --no-startup-id xbrlapi --quiet'
fi
if [[ -x "/usr/lib/notification-daemon-1.0/notification-daemon" ]]; then
    echo 'exec_always --no-startup-id /usr/lib/notification-daemon-1.0/notification-daemon -r'
fi
if [[ $dex -eq 0 ]]; then
    echo '# Start XDG autostart .desktop files using dex. See also'
    echo '# https://wiki.archlinux.org/index.php/XDG_Autostart'
    echo 'exec --no-startup-id dex --autostart --environment i3'
else
    echo '# Startup applications'
    echo 'exec clipster -d'
    echo 'exec orca'
fi)

# If you want to add personal customizations to i3, add them in ${i3Path}/customizations
# It is not overwritten with the config file is recreated.
$(if [[ -r "${i3Path}/customizations" ]]; then
    echo "include \"${i3Path}/customizations\""
else
    echo "# Rerun the ${0##*/} script after creating the customizations file so it is detected."
fi)
EOF
