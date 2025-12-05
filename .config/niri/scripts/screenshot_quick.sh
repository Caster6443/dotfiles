#!/usr/bin/env bash
# 快速全屏截图 -> 保存文件 + 强制写入剪贴板 + 通知

# 1. 设置路径
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot_$(date '+%Y%m%d_%H%M%S').png"

# 2. 截图 (使用 grim)
if grim "$FILE"; then
  # 使用 cat 读取文件流，通过管道传给 wl-copy
  # --type image/png: 明确告诉剪贴板这是图片，别当成文本处理
  if command -v wl-copy >/dev/null 2>&1; then
      cat "$FILE" | wl-copy --type image/png
  else
      notify-send -a "Screenshot" "错误" "未找到 wl-copy，无法复制到剪贴板" -u critical
  fi

  # 4. 发送成功通知
  notify-send -a "Screenshot" "已保存并复制" "文件名: $(basename "$FILE")" -i "$FILE" --hint=int:transient:1
  exit 0

else
  # 失败处理
  notify-send -a "Screenshot" "截图失败" "grim 执行出错" -u critical
  rm -f "$FILE" 2>/dev/null
  exit 1
fi
