#!/bin/bash

# 目标大页数量（8300个 2MB大页 ≈ 16.2GB，完美覆盖虚拟机的需求）
TARGET_HP=8300

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 sudo 运行此脚本！(例如: sudo ./enable_hugepages.sh)"
  exit 1
fi

echo "========================================="
echo "  正在准备虚拟机环境：分配 2MB 内存大页"
echo "========================================="

echo "[1/3] 正在清理系统缓存释放空间..."
sync
echo 3 >/proc/sys/vm/drop_caches
sleep 1
# （已安全移除会导致宿主机死机的 compact_memory 指令）

echo "[2/3] 正在申请 $TARGET_HP 个大页..."
sysctl -w vm.nr_hugepages=$TARGET_HP >/dev/null

echo "[3/3] 验证分配结果..."
ALLOCATED=$(cat /proc/sys/vm/nr_hugepages)

echo "-----------------------------------------"
# 虚拟机 + Looking Glass 总共需要 8224，我们将安全底线设为 8250
if [ "$ALLOCATED" -ge 8250 ]; then
  echo "✅ 成功！实际分配大页数量: $ALLOCATED"
  echo "👉 现在可以直接启动 win11 虚拟机了。"
else
  echo "⚠️ 警告：分配数量不足！"
  echo "预期: $TARGET_HP，实际只分配了: $ALLOCATED"
  echo "原因：当前系统运行较久，内存碎片过多，无法找出大段连续空间。"
  echo "💡 解决方法：请【重启电脑】后，第一时间运行此脚本即可成功。"

  # 分配失败时，将已分配的残余大页释放，避免浪费宿主机内存
  sysctl -w vm.nr_hugepages=0 >/dev/null
fi
echo "========================================="
