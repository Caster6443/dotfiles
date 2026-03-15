#!/bin/bash

# 接收从启动器传来的壁纸绝对路径
WALLPAPER_PATH="$1"

# 1. 用原版程序算颜色（静默执行，不让它真换壁纸）
/usr/bin/caelestia wallpaper -f "$WALLPAPER_PATH" &

# 2. 用 swww 播放无敌动画
swww img "$WALLPAPER_PATH" --transition-type grow --transition-pos 0.5,0.5 --transition-step 90 --transition-fps 60
