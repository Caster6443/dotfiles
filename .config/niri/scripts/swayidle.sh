#!/usr/bin/env bash

# 定义 swayidle 的启动命令
# 注意：这里去掉了 timeout 前面的判断逻辑，恢复为最原始、最纯净的命令
# 因为判断逻辑现在由外层的 while 循环接管了
START_SWAYIDLE() {
    swayidle -w \
        timeout 300  'swaylock -f' \
        timeout 600  'niri msg action power-off-monitors' \
        resume       'niri msg action power-on-monitors' \
        timeout 1200 'systemctl suspend' &
}

# 停止 swayidle 的函数
STOP_SWAYIDLE() {
    if pgrep -x "swayidle" > /dev/null; then
        killall swayidle
    fi
}

# 脚本退出时清理现场
trap STOP_SWAYIDLE SIGINT SIGTERM

echo "Swayidle Manager Started..."

while true; do
    # 1. 检查是否存在 Noctalia 的抑制锁
    # 搜索你提供的日志中的特征字符串: "Manually activated by user"
    if systemd-inhibit --list --no-pager | grep -q "Manually activated by user"; then
        # === 发现抑制锁 (Noctalia 开启中) ===
        
        # 如果 swayidle 正在运行，就杀掉它
        if pgrep -x "swayidle" > /dev/null; then
            echo "Inhibitor detected. Killing swayidle..."
            STOP_SWAYIDLE
        fi
        
    else
        # === 没有抑制锁 (Noctalia 关闭) ===
        
        # 如果 swayidle 没有运行，就启动它
        if ! pgrep -x "swayidle" > /dev/null; then
            echo "No inhibitor. Starting swayidle..."
            START_SWAYIDLE
        fi
    fi

    # 每 5 秒检查一次
    sleep 5
done
