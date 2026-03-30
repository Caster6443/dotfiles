#!/bin/bash
echo "开始安全唤醒 RTX 4060..."

# 1. 强制通电 (笔记本防死锁核心，必须在操作前进行)
echo "on" | sudo tee /sys/bus/pci/devices/0000:01:00.0/power/control >/dev/null 2>&1
echo "on" | sudo tee /sys/bus/pci/devices/0000:01:00.1/power/control >/dev/null 2>&1
sleep 1

# 2. 提前加载基础模块
sudo modprobe nvidia
sudo modprobe nvidia_modeset
sudo modprobe nvidia_uvm

# 函数：智能解绑与认领 (修复了声卡错绑 Bug)
bind_to_driver() {
  PCI_ID=$1
  TARGET_DRIVER=$2

  # 检查并解绑旧驱动
  if [ -L "/sys/bus/pci/devices/$PCI_ID/driver" ]; then
    CURRENT_DRIVER=$(basename $(readlink /sys/bus/pci/devices/$PCI_ID/driver))
    if [ "$CURRENT_DRIVER" != "$TARGET_DRIVER" ]; then
      echo "设备 $PCI_ID 当前被 $CURRENT_DRIVER 占用，正在解绑..."
      echo "$PCI_ID" | sudo tee /sys/bus/pci/drivers/$CURRENT_DRIVER/unbind >/dev/null
    fi
  fi

  # 打上目标驱动的钢印并探测
  echo "$TARGET_DRIVER" | sudo tee /sys/bus/pci/devices/$PCI_ID/driver_override >/dev/null
  echo "$PCI_ID" | sudo tee /sys/bus/pci/drivers_probe >/dev/null

  # 探测完毕后，擦除钢印 (保持系统纯净)
  echo "" | sudo tee /sys/bus/pci/devices/$PCI_ID/driver_override >/dev/null
}

# 3. 分别绑定显卡(nvidia)和声卡(snd_hda_intel) —— 绝对不能搞混！
bind_to_driver "0000:01:00.0" "nvidia"
bind_to_driver "0000:01:00.1" "snd_hda_intel"

# 4. 显卡就位后，最后加载 DRM 模块 (确保生成 /dev/dri/card 节点)
sudo modprobe nvidia_drm

# 5. 恢复底层控制台文字输出 (修复关机/重启没有日志的问题)
echo 1 | sudo tee /sys/class/vtconsole/vtcon1/bind >/dev/null 2>&1

echo "唤醒流程完美结束！"
