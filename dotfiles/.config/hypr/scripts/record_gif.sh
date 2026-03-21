#!/bin/bash

# 定义最终 GIF 保存路径
SAVE_DIR="$HOME/Pictures/GIFs"
mkdir -p "$SAVE_DIR"

# 临时视频文件路径 (放在 /tmp 目录下，存取速度极快，重启会自动清理)
TMP_FILE="/tmp/hypr_record_temp.mp4"

# 检查 wf-recorder 是否在运行
if pgrep -x "wf-recorder" >/dev/null; then
  # 1. 弹出转换提示并停止录屏
  notify-send -u normal "⏳ 正在生成 GIF..." "请稍候..."
  killall -s SIGINT wf-recorder

  # 2. 等待 wf-recorder 完全退出，确保视频文件写完
  while pgrep -x "wf-recorder" >/dev/null; do sleep 0.1; done

  # 3. 准备生成最终的 GIF 文件名
  FINAL_GIF="$SAVE_DIR/录屏_$(date +'%Y%m%d_%H%M%S').gif"

  # 4. 核心：调用 ffmpeg 将刚才录的 MP4 高质量转换为 GIF
  # (使用了调色板技术，保证画质清晰且体积小，fps=15 保证流畅度)
  ffmpeg -i "$TMP_FILE" -vf "fps=15,scale=1024:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "$FINAL_GIF" -y

  # 5. 删除临时 MP4 文件
  rm "$TMP_FILE"

  notify-send -u critical "✅ GIF 录制完成" "已保存至 $SAVE_DIR"
else
  # 准备录制
  notify-send -u low "🎯 准备录制 GIF" "请用鼠标框选区域..."

  # 让用户框选，保存坐标
  GEOM=$(slurp)

  # 如果用户按了 ESC 取消框选，就直接退出
  if [ -z "$GEOM" ]; then
    exit 0
  fi

  # 使用最稳定、绝对不会崩溃的 mp4 格式开始后台录制
  wf-recorder -g "$GEOM" -f "$TMP_FILE" &

  # 延迟半秒，确认程序正常存活
  sleep 0.5
  if pgrep -x "wf-recorder" >/dev/null; then
    notify-send -u critical "🔴 正在录制..." "再次按下快捷键停止录制"
  else
    notify-send -u critical "❌ 录制失败" "请检查依赖"
  fi
fi
