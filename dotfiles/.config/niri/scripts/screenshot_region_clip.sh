#!/usr/bin/env bash
# 区域截图 -> 只进剪贴板（效果对齐 Hyprland 的 SUPER+SHIFT+S = caelestia:screenshotFreezeClip）
#
# 两点关键效果与 Hyprland 保持一致：
#   1) 先冻结画面再选区域：选区内容取自「按下快捷键那一刻」的画面，
#      这样才能截到一交互就消失的菜单 / 悬浮提示；
#   2) 结果只写剪贴板，不落盘。
#
# 实现层差异（用户已确认不关心）：选区界面由 slurp 提供，
# 没有 caelestia 那套窗口吸附与圆角预览。
set -o pipefail

FROZEN="$(mktemp --tmpdir niri-freeze-XXXXXX.png)"
CROP="$(mktemp --tmpdir niri-crop-XXXXXX.png)"
trap 'rm -f "$FROZEN" "$CROP"' EXIT

# grim -s 1 yields one pixel per logical unit. Its canvas starts at
# the top-left of the active output bounding box, not global (0, 0).
OUTPUTS="$(niri msg --json outputs)" || exit 1
ORIGIN_X="$(jq -er '[.[] | .logical // empty | .x] | min // error("no active output")' <<< "$OUTPUTS")" || exit 1
ORIGIN_Y="$(jq -er '[.[] | .logical // empty | .y] | min // error("no active output")' <<< "$OUTPUTS")" || exit 1
if ! grim -s 1 "$FROZEN"; then
    notify-send -a Screenshot "截图失败" "冻结画面失败（grim）" -u critical
    exit 1
fi

GEOM="$(slurp)" || exit 0            # 按 Esc 取消选择 -> 静默退出
[ -z "$GEOM" ] && exit 0

# slurp 输出形如 "640,480 320x240"，转成 ImageMagick 的 "320x240+640+480"
X="${GEOM%%,*}"
rest="${GEOM#*,}"
Y="${rest%% *}"
WH="${rest##* }"
case "$WH" in
    0x*|*x0) exit 0 ;;              # 没真正拖出区域
esac

X=$((X - ORIGIN_X))
Y=$((Y - ORIGIN_Y))
if ! magick "$FROZEN" -crop "${WH}+${X}+${Y}" +repage "$CROP"; then
    notify-send -a Screenshot "截图失败" "从冻结帧裁剪失败（magick）" -u critical
    exit 1
fi

wl-copy --type image/png < "$CROP"
notify-send -a Screenshot -i "$CROP" "区域截图已复制到剪贴板" --hint=int:transient:1
