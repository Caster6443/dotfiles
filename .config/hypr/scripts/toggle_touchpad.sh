#!/usr/bin/env bash

DEVICE_TOUCHPAD="asuf1204:00-2808:0202-touchpad"

# 状态文件
STATE_FILE="/tmp/hypr_touchpad.state"

if [ -f "$STATE_FILE" ]; then
    # --- 状态文件存在，说明触控板当前是【禁用】的 ---
    # --- 目标：【启用】它 ---
    hyprctl keyword "device[$DEVICE_TOUCHPAD]:enabled" 'true'
    
    notify-send "Touchpad" "已启用 ✅" -u low
    rm "$STATE_FILE"
else
    # --- 状态文件不存在，说明触控板当前是【启用】的 ---
    # --- 目标：【禁用】它 ---
    
    # 使用你找到的正确语法
    hyprctl keyword "device[$DEVICE_TOUCHPAD]:enabled" 'false'
    
    notify-send "Touchpad" "已禁用 ⛔" -u low
    touch "$STATE_FILE"
fi
