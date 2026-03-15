#!/bin/bash

while true; do
  RANDOM_IMG=$(find ~/Pictures/Wallpapers -type f \( -iname \*.jpg -o -iname \*.png \) | shuf -n 1)

  caelestia wallpaper -f "$RANDOM_IMG"

  sleep 600
done
