#!/bin/bash

if [ -f /tmp/nvidia_is_awake ]; then
  echo "本次开机已经唤醒过显卡，跳过执行，防止死锁。"
  exit 0
fi

sudo /home/caster/.config/hypr/scripts/wake_nvidia.sh

touch /tmp/nvidia_is_awake
