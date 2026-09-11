#!/usr/bin/env bash
# 按清单把 $HOME 的 dotfiles 镜像到仓库并提交/推送。
# 由 systemd 用户定时器调用（dotfiles-sync.timer），也可手动运行。
set -uo pipefail

REPO="${HOME}/Github_repos/Dotfiles"
cd "${REPO}" || exit 1

log() { printf '%s\n' "$*"; }

sync_file() {
  local src="$1" dst="$2"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
    log "同步: $dst"
  else
    log "跳过(源缺失): $src"
  fi
}

sync_dir() {
  local src="$1" dst="$2"
  shift 2
  if [[ -d "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    local args=(-a --delete)
    for ex in "$@"; do args+=("--exclude=${ex}"); done
    rsync "${args[@]}" "$src/" "$dst/"
    log "同步: $dst/"
  else
    log "跳过(源缺失): $src/"
  fi
}

# --- 家目录散件 ---
sync_file "${HOME}/.zshrc"           "dotfiles/.zshrc"

# aichat.json：只备份非敏感项，apiKey 一律抹成空串写进仓库（运行配置原文件不动）。
# 换机后从仓库恢复时，key 需要重新在面板 ⚙ 里填一次。
sync_aichat_config() {
  local src="${HOME}/.config/caelestia/aichat.json"
  local dst="dotfiles/.config/caelestia/aichat.json"
  if [[ ! -f "$src" ]]; then
    log "跳过(源缺失): $src"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if python3 - "$src" "$dst" <<'PY'
import json
import os
import sys

src, dst = sys.argv[1], sys.argv[2]
with open(src, encoding="utf-8") as f:
    cfg = json.load(f)
if not isinstance(cfg, dict):
    raise SystemExit("aichat.json 顶层不是对象，拒绝写入")
cfg["apiKey"] = ""
tmp = dst + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent="\t", ensure_ascii=False)
    f.write("\n")
os.chmod(tmp, 0o644)
os.replace(tmp, dst)
PY
  then
    log "同步(apiKey 已抹空): $dst"
  else
    log "!! aichat.json 处理失败，已跳过（不会原样同步）"
  fi
}
sync_file "${HOME}/.gitconfig"       "dotfiles/.gitconfig"
sync_file "${HOME}/.vimrc"           "dotfiles/.vimrc"
sync_file "${HOME}/.gtkrc-2.0"       "dotfiles/.gtkrc-2.0"

# --- 桌面/窗口管理 ---
sync_dir "${HOME}/.config/hypr"      "dotfiles/.config/hypr" _binds_raw.json
sync_dir "${HOME}/.config/niri"      "dotfiles/.config/niri"
sync_dir "${HOME}/.config/waybar"    "dotfiles/.config/waybar"
# aichat.json 内含 API key（600 权限），**原样绝不入库**：2026-09-11 曾误同步进公开仓库导致 key 泄露。
# 这里先整体 exclude 挡住原文件，紧接着用 sync_aichat_config 写入"apiKey 已抹空"的副本。
sync_dir "${HOME}/.config/caelestia" "dotfiles/.config/caelestia" aichat.json
sync_aichat_config

# --- 终端/编辑器/常用工具 ---
sync_dir "${HOME}/.config/kitty"     "dotfiles/.config/kitty"
sync_dir "${HOME}/.config/foot"      "dotfiles/.config/foot"
sync_dir "${HOME}/.config/fuzzel"    "dotfiles/.config/fuzzel"
sync_dir "${HOME}/.config/fish"      "dotfiles/.config/fish"
sync_dir "${HOME}/.config/nvim"      "dotfiles/.config/nvim"
sync_dir "${HOME}/.config/rmpc"      "dotfiles/.config/rmpc"
sync_dir "${HOME}/.config/mpDris2"   "dotfiles/.config/mpDris2"
sync_dir "${HOME}/.config/fastfetch" "dotfiles/.config/fastfetch"

# --- 媒体（mpd 只备份配置，运行时文件不备份）---
sync_file "${HOME}/.config/mpd/mpd.conf" "dotfiles/.config/mpd/mpd.conf"

# --- 系统级用户配置 ---
sync_dir "${HOME}/.config/systemd/user"      "dotfiles/.config/systemd/user"
sync_dir "${HOME}/.config/gtk-3.0"           "dotfiles/.config/gtk-3.0"
sync_dir "${HOME}/.config/gtk-4.0"           "dotfiles/.config/gtk-4.0"
sync_dir "${HOME}/.config/fcitx5"            "dotfiles/.config/fcitx5" conf/cached_layouts
sync_dir "${HOME}/.config/environment.d"     "dotfiles/.config/environment.d"
sync_file "${HOME}/.config/mimeapps.list"    "dotfiles/.config/mimeapps.list"
sync_file "${HOME}/.config/monitors.xml"     "dotfiles/.config/monitors.xml"
sync_file "${HOME}/.config/user-dirs.dirs"   "dotfiles/.config/user-dirs.dirs"

# --- 提交 ---
# 推送前凭据自检（2026-09-11 aichat.json API key 泄露事故后添加）：
# 扫描本次「新增」行里是否出现 key/私钥特征，命中就中止提交与推送，等人工处理。
# 这是兜底：正常做法是把含凭据的文件加进上面 sync_dir 的 --exclude 和 .gitignore。
SECRET_PATTERN='sk-[A-Za-z0-9_-]{16,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY|"(apiKey|api_key|apikey|secret|token|password|passwd)"[[:space:]]*:[[:space:]]*"[^"]{16,}"'
staged_secret_hits() {
  git diff --cached -U0 -- dotfiles/ .gitignore sync-dotfiles.sh |
    grep -E '^\+' | grep -vE '^\+\+\+' | grep -nEi -- "$SECRET_PATTERN"
}
SECRET_BLOCK=0

if [[ -n "$(git status --porcelain -- dotfiles/ .gitignore sync-dotfiles.sh)" ]]; then
  git add -A dotfiles/ .gitignore sync-dotfiles.sh
  hits="$(staged_secret_hits || true)"
  if [[ -n "$hits" ]]; then
    SECRET_BLOCK=1
    log "!! 凭据自检命中，已中止本次提交与推送："
    printf '%s\n' "$hits"
    log "   处理：确认该文件不含密钥；若确实是凭据文件，给它加 --exclude（sync_dir 第 3 个参数）并在 .gitignore 兜一条，然后重跑本脚本。"
  else
    git commit -m "sync: $(date '+%F %T') dotfiles 自动同步" --quiet || true
    log "已提交"
  fi
else
  log "无变更"
fi

# --- 推送（失败不阻塞，下次自动重试）---
if [[ "$SECRET_BLOCK" -eq 1 ]]; then
  log "因凭据自检命中，本次不推送"
elif git remote get-url origin >/dev/null 2>&1; then
  if timeout 60 git push origin main 2>&1; then
    log "已推送到 origin/main"
  else
    log "推送失败（网络或凭据问题），本地已提交，留待下次重试"
  fi
fi
