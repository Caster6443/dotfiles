#!/usr/bin/env bash
# 区域截图 -> 丢进 swappy 编辑（效果对齐 Hyprland 的 ALT+SHIFT+S = caelestia:screenshotFreeze）
#
# 与 Hyprland 一致：先冻结画面再选区域，选区内容取自按下快捷键那一刻；
# 之后不落盘、不进剪贴板，直接打开 swappy，保存/复制由 swappy 自己决定（Ctrl+S 保存、Ctrl+C 复制）。
set -o pipefail

FROZEN="$(mktemp --tmpdir niri-freeze-XXXXXX.png)"
CROP="$(mktemp --tmpdir niri-crop-XXXXXX.png)"
trap 'rm -f "$FROZEN" "$CROP"' EXIT

if ! grim "$FROZEN"; then
    notify-send -a Screenshot "截图失败" "冻结画面失败（grim）" -u critical
    exit 1
fi

GEOM="$(slurp)" || exit 0
[ -z "$GEOM" ] && exit 0

X="${GEOM%%,*}"
rest="${GEOM#*,}"
Y="${rest%% *}"
WH="${rest##* }"
case "$WH" in
    0x*|*x0) exit 0 ;;
esac

if ! magick "$FROZEN" -crop "${WH}+${X}+${Y}" +repage "$CROP"; then
    notify-send -a Screenshot "截图失败" "从冻结帧裁剪失败（magick）" -u critical
    exit 1
fi

# 前台运行：swappy 读的就是这个临时文件，脚本退出前不能删（trap 在 swappy 结束后才清理）
swappy -f "$CROP"
