#!/bin/bash

GPU_PCI="0000:01:00.0"
AUD_PCI="0000:01:00.1"

# 停止N卡电源和持久化服务，释放硬件控制权
systemctl stop nvidia-powerd 2>/dev/null
systemctl stop nvidia-persistenced 2>/dev/null

# 从内核卸载NVIDIA全家桶驱动
modprobe -r nvidia_drm nvidia_uvm nvidia_modeset nvidia 2>/dev/null

# 将伴生声卡从系统原生音频驱动中强制剥离
if [ -d "/sys/bus/pci/drivers/snd_hda_intel/$AUD_PCI" ]; then
  echo "$AUD_PCI" >/sys/bus/pci/drivers/snd_hda_intel/unbind
fi

# 加载VFIO模块在后台待命，剩下的移交工作由Libvirt(managed=yes)自动完成
modprobe vfio-pci
