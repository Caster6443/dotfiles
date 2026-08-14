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
sync_file "${HOME}/.gitconfig"       "dotfiles/.gitconfig"
sync_file "${HOME}/.vimrc"           "dotfiles/.vimrc"
sync_file "${HOME}/.gtkrc-2.0"       "dotfiles/.gtkrc-2.0"

# --- 桌面/窗口管理 ---
sync_dir "${HOME}/.config/hypr"      "dotfiles/.config/hypr" _binds_raw.json
sync_dir "${HOME}/.config/niri"      "dotfiles/.config/niri"
sync_dir "${HOME}/.config/waybar"    "dotfiles/.config/waybar"
sync_dir "${HOME}/.config/caelestia" "dotfiles/.config/caelestia"

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
if [[ -n "$(git status --porcelain -- dotfiles/ .gitignore sync-dotfiles.sh)" ]]; then
  git add -A dotfiles/ .gitignore sync-dotfiles.sh
  git commit -m "sync: $(date '+%F %T') dotfiles 自动同步" --quiet || true
  log "已提交"
else
  log "无变更"
fi

# --- 推送（失败不阻塞，下次自动重试）---
if git remote get-url origin >/dev/null 2>&1; then
  if timeout 60 git push origin main 2>&1; then
    log "已推送到 origin/main"
  else
    log "推送失败（网络或凭据问题），本地已提交，留待下次重试"
  fi
fi
