#!/usr/bin/env bash

mapfile -t windowList < <(python3 -c '
import i3ipc

i3 = i3ipc.Connection()

for con in i3.get_tree():
    if con.window and con.parent.type != "dockarea":
        print(con.window)
        print(con.name)')
id="$(yad --title "I38" --list --separator "" --column "id" --column "Select Window" --hide-column 1 --print-column 1 "${windowList[@]}")"
if [[ -z "${id}" ]]; then
    exit 0
fi
i3-msg \[id="${id}"\] focus
