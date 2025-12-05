#rm -f ~/.zcompdump 
export PATH=$PATH:$(go env GOPATH)/bin
# 1. 设置历史记录
# -----------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY

# 2. 别名与颜色
# -----------------------------------------------------------------
alias ls='ls --color=auto'
alias l='ls -CF --color=auto'
alias la='ls -A --color=auto'
alias ll='ls -lA --color=auto'
eval "$(dircolors -b)"

# 3. 补全样式o
# -----------------------------------------------------------------
zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors $LS_COLORS

# 4. 加载 Zsh 自动建议插件a
# -----------------------------------------------------------------
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# 5. 激活 Starship 提示符u
# -----------------------------------------------------------------
eval "$(starship init zsh)"

# 6. 自动补全s
# -----------------------------------------------------------------
autoload -Uz compinit
compinit

# 7. 加载语法高亮插件t
# -----------------------------------------------------------------
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.
