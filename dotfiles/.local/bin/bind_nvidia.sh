#!/bin/bash

GPU_PCI="0000:01:00.0"
AUD_PCI="0000:01:00.1"

# 1. 清除所有的驱动覆写规则，防止后续绑定混乱
echo "" >/sys/bus/pci/devices/$GPU_PCI/driver_override
echo "" >/sys/bus/pci/devices/$AUD_PCI/driver_override

# 2. 将显卡和声卡从 VFIO 驱动中剥离
if [ -d "/sys/bus/pci/drivers/vfio-pci/$GPU_PCI" ]; then
  echo "$GPU_PCI" >/sys/bus/pci/drivers/vfio-pci/unbind
fi
if [ -d "/sys/bus/pci/drivers/vfio-pci/$AUD_PCI" ]; then
  echo "$AUD_PCI" >/sys/bus/pci/drivers/vfio-pci/unbind
fi

# 3. 重新加载 NVIDIA 驱动栈
modprobe nvidia
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe nvidia_uvm

# 4. 触发内核重新探测硬件，驱动正式接管设备
echo "$GPU_PCI" >/sys/bus/pci/drivers_probe
echo "$AUD_PCI" >/sys/bus/pci/drivers_probe

# 5. (可选) 重新启动持久化服务，保持驱动就绪状态
systemctl start nvidia-persistenced 2>/dev/null
