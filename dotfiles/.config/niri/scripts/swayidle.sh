#!/usr/bin/env bash

# 定义 PID 变量
PID=0

# 启动函数
start_swayidle() {
    # 只有当 PID 为 0 或进程不存在时才启动
    if [[ $PID -eq 0 ]] || ! kill -0 "$PID" 2>/dev/null; then
        swayidle -w \
            timeout 300  'swaylock -f' \
            timeout 600  'niri msg action power-off-monitors' \
            resume       'niri msg action power-on-monitors' \
            timeout 1200 'systemctl suspend' &
        PID=$! # 记录 swayidle 的进程 ID
    fi
}

# 停止函数 (关机触发)
cleanup() {
    # 简单粗暴：如果有 PID，直接杀掉，不等待，不废话
    if [[ $PID -ne 0 ]]; then
        kill -9 "$PID" 2>/dev/null
    fi
    exit 0
}

# 捕捉信号：一旦收到关机信号，立即跳转到 cleanup
trap cleanup SIGTERM SIGINT

echo "Swayidle Manager Started..."

while true; do
    # 使用 timeout 防止 systemd-inhibit 在关机时卡死 (关键修复)
    if timeout 2s systemd-inhibit --list --no-pager | grep -q "Manually activated by user"; then
        # === 发现抑制锁 ===
        if [[ $PID -ne 0 ]] && kill -0 "$PID" 2>/dev/null; then
            kill "$PID" 2>/dev/null
            PID=0
        fi
    else
        # === 正常状态 ===
        start_swayidle
    fi

    # 【关键技巧】将 sleep 放入后台并 wait，这样信号能瞬间打断等待
    sleep 5 &
    wait $!
done
