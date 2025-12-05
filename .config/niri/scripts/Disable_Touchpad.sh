#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/niri/config.kdl"

IS_DISABLED=$(awk '/touchpad \{/,/\}/ { if ($0 ~ /^[[:space:]]*off/) print "yes" }' "$CONFIG_FILE")

if [ "$IS_DISABLED" == "yes" ]; then
    sed -i '/touchpad {/,/}/ s/^[[:space:]]*off/        \/\/ off/' "$CONFIG_FILE"
    MSG="已启用 ✅"
else
    sed -i '/touchpad {/,/}/ s/^[[:space:]]*\/\/ off/        off/' "$CONFIG_FILE"
    MSG="已禁用 ⛔"
fi

notify-send "Touchpad" "$MSG" -u low
