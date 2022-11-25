#!/usr/bin/env bash

select_window() {
    local window="$(yad --list --column "Select Window" "$@")"
    echo "${window%|}"
}

i3-msg '[title="'$(i3-msg -t get_tree | jq -r "recurse(.nodes[]) | select(.window) | .name" | select_window)'"] focus'

exit 0
