#!/bin/bash


run_command() {
    playerctl -p '%any,chromium,firefox' $1
    sleep 0.25
}

show_info() {
    info="$( playerctl -p '%any,chromium,firefox' metadata -f '"{{title}}" by "{{artist}}" from "{{album}}"')"
    local count=1
    while [[ $count -le 10 ]] && [[ "$info" == "$oldInfo" ]]; do
        info="$(playerctl -p '%any,chromium,firefox' metadata -f '"{{title}}" by "{{artist}}" from "{{album}}"')"
        ((count++))
        sleep 0.25
    done
    notify-send "$info"
    exit 0
}


    oldInfo="$(playerctl -p '%any,chromium,firefox' metadata -f '"{{title}}" by "{{artist}}" from "{{album}}"')"
volume="0${2}"
volume=${volume: -2}
case "${1}" in
    "prev") run_command "previous";show_info;;
    "play") run_command "play";show_info;;
    "pause") run_command "play-pause";;
    "stop") run_command "stop";;
    "next") run_command "next";show_info;;
    "shuf") run_command "shuffle toggle";;
    "info") unset oldInfo;show_info;;
    "decvol") run_command "volume 0.${volume}-";;
    "incvol") run_command "volume 0.${volume}+";;
esac

exit 0
