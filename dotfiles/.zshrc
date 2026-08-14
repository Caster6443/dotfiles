# =============================================================================
# 1. 基础环境与路径 
# =============================================================================
# 加载用户环境变量
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# 基础编辑器设置
export EDITOR=${EDITOR:-vim}
export PAGER=${PAGER:-less}

# =============================================================================
# 2. 历史记录设置
# =============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000           # 适当增加，配合去重功能
SAVEHIST=10000
setopt APPEND_HISTORY    # 追加而不是覆盖
setopt EXTENDED_HISTORY  # 记录时间戳
setopt HIST_EXPIRE_DUPS_FIRST # 空间不足时优先删除重复项
setopt HIST_IGNORE_DUPS  # 不记录连续重复的命令
setopt HIST_IGNORE_SPACE # 空格开头的命令不记录 (输密码时有用)
setopt SHARE_HISTORY     # 多个终端共享历史
setopt HIST_VERIFY       # 使用历史命令时先显示，回车才执行

# =============================================================================
# 3. 智能补全系统 (源自 Grml 的核心)
# =============================================================================
# 加载补全模块
autoload -Uz compinit
# 检查缓存，加快启动速度
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# 补全样式设置
zstyle ':completion:*' menu select                              # 启用菜单选择
zstyle ':completion:*' rehash true                              # 自动更新 PATH 变更
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # 忽略大小写
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}           # 补全列表使用 ls 颜色
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31' # kill 命令补全时高亮 PID
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# 修正建议 (如果不喜欢输错命令时 zsh 问你 "did you mean...", 将下面改为 false)
zstyle ':completion:*:correct:*' original true
zstyle ':completion:*:correct:*' insert-unambiguous true
setopt correct                                                  # 开启命令纠错

# =============================================================================
# 4. 实用别名 
# =============================================================================
# --- 自定义别名 ---
alias ls='ls --color=auto'
alias l='ls -CF --color=auto'
alias la='ls -A --color=auto'
alias ll='ls -lA --color=auto'
alias rmpc="rmpc; mpc stop"
alias rm='trash-put'

eval "$(dircolors -b)"
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'

# Global Aliases (Grml 特色功能)
# 用法: cat filename G foo (相当于 cat filename | grep foo)
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g N='> /dev/null'

# =============================================================================
# 5. 实用函数 (源自 Grml & Keephack)
# =============================================================================

# [Keephack] 即使不用 root 权限也能保留命令输出
# 用法: locate -i backup | keep
function keep {
    setopt localoptions nomarkdirs nonomatch nocshnullglob nullglob
    kept=()
    kept=($~*)
    if [[ ! -t 0 ]]; then
        local line
        while read line; do
            kept+=( $line )
        done
    fi
    print -Rc - ${^kept%/}(T)
}
alias keep='noglob keep'

# [mkcd] 创建目录并进入
function mkcd() {
    if (( ARGC != 1 )); then
        printf 'usage: mkcd <new-directory>\n'
        return 1
    fi
    if [[ ! -d "$1" ]]; then
        command mkdir -p "$1"
    else
        printf '`%s'\'' already exists: cd-ing.\n' "$1"
    fi
    builtin cd "$1"
}

# [bk] 快速备份文件
# 用法: bk file.txt -> file.txt_20231206...
function bk() {
    emulate -L zsh
    local current_date=$(date -u "+%Y%m%dT%H%M%SZ")
    cp -a "$1" "${1}_$current_date"
}

# [simple-extract] 智能解压 (替代 xsource/simple-extract)
# 用法: se archive.tar.gz
function se() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf $1   ;;
            *.tar.gz)    tar xzf $1   ;;
            *.bz2)       bunzip2 $1   ;;
            *.rar)       unrar x $1   ;;
            *.gz)        gunzip $1    ;;
            *.tar)       tar xf $1    ;;
            *.tbz2)      tar xjf $1   ;;
            *.tgz)       tar xzf $1   ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1      ;;
            *)           echo "'$1' cannot be extracted via se()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# =============================================================================
# 6. 快捷键绑定
# =============================================================================
bindkey -e  # Emacs 模式 (标准 Linux 终端习惯)

# 历史记录搜索 (输入部分命令后按上下键)
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search    # Up Arrow
bindkey "^[[B" down-line-or-beginning-search  # Down Arrow

# 额外的快捷键
bindkey '^R' history-incremental-search-backward # Ctrl-R 搜索历史

# =============================================================================
# 7. 插件与外观 
# =============================================================================

# 加载 zsh-autosuggestions (如果存在)
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# 激活 Starship 提示符 
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"
fi

# 加载 zsh-syntax-highlighting (必须是文件的最后一行加载)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
