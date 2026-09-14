#!/usr/bin/env bash
# 全屏截图（聚焦显示器）-> 剪贴板 + 落盘 + 通知（可一键编辑）
# 效果对齐 Hyprland 的 Print = caelestia screenshot（无参数）：
#   那边是 grim 聚焦显示器 -> wl-copy -> 存 ~/.cache/caelestia/screenshots/<时间戳>，
#   再弹通知，通知里 Open=swappy 编辑 / Save=移进 ~/Pictures/Screenshots。
#   这里把两步合并：直接落 ~/Pictures/Screenshots，通知里给「编辑」按钮。
#
# 与 Hyprland 的差异（有意为之）：
#   - caelestia CLI 的 wl-copy 没带 --type，粘出来是 text mimetype；这里显式 image/png。
set -o pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot_$(date '+%Y%m%d_%H%M%S').png"

# 聚焦显示器名（niri IPC）；取不到就退回「所有输出」整屏
OUTPUT="$(niri msg --json focused-output 2>/dev/null | jq -r '.name // empty' 2>/dev/null)"
if [ -n "$OUTPUT" ]; then
    grim -o "$OUTPUT" "$FILE" || { notify-send -a Screenshot "截图失败" "grim 执行出错" -u critical; rm -f "$FILE"; exit 1; }
else
    grim "$FILE" || { notify-send -a Screenshot "截图失败" "grim 执行出错" -u critical; rm -f "$FILE"; exit 1; }
fi

wl-copy --type image/png < "$FILE"

# -A 会隐含 --wait，并把用户点到的动作名打到 stdout；不支持动作的通知守护也不会报错卡死
ACTION="$(notify-send -a Screenshot -i "$FILE" -h "string:image-path:$FILE" \
    -A edit=编辑 "已截图并保存" "$(basename "$FILE")（已复制到剪贴板）" 2>/dev/null || true)"

if [ "$ACTION" = "edit" ]; then
    swappy -f "$FILE"
fi
exit 0
