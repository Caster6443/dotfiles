#!/bin/bash

echo efi-framebuffer.0 | sudo tee /sys/bus/platform/drivers/efi-framebuffer/unbind

# 停止 NVIDIA 服务
sudo systemctl stop nvidia-persistenced.service 2>/dev/null

# 解绑显卡与声卡
echo "0000:01:00.0" | sudo tee /sys/bus/pci/drivers/nvidia/unbind
echo "0000:01:00.1" | sudo tee /sys/bus/pci/drivers/snd_hda_intel/unbind 2>/dev/null

# 强塞给 VFIO 并探测
echo "vfio-pci" | sudo tee /sys/bus/pci/devices/0000:01:00.0/driver_override
echo "vfio-pci" | sudo tee /sys/bus/pci/devices/0000:01:00.1/driver_override
echo "0000:01:00.0" | sudo tee /sys/bus/pci/drivers_probe
echo "0000:01:00.1" | sudo tee /sys/bus/pci/drivers_probe

# 确保控制台输出正常，不设置的话也没事，但是关机就不显示日志了
echo 1 | sudo tee /sys/class/vtconsole/vtcon1/bind
