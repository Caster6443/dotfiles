# Arch grml-zsh-config 0.20.2-1，Arch Live ISO 使用同一软件包。
# https://archlinux.org/packages/extra/any/grml-zsh-config/
typeset -U path PATH
path=("$HOME/.local/bin" "${path[@]}")
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

source "$HOME/.local/share/grml-zsh/arch-zshrc"
if [[ ! -r /etc/zsh/keephack ]]; then
    source "$HOME/.local/share/grml-zsh/keephack"
fi

export EDITOR=${EDITOR:-vim}
export PAGER=${PAGER:-less}

# 本机命令与快捷方式。
alias ls='eza --icons --group-directories-first -1'
alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias rmpc="rmpc; mpc stop"
alias rm='trash-put'

# 沿用 Fish 的常用命令和 Git 缩写。
alias getaudio='yt-dlp -x --audio-format mp3 --no-playlist --embed-thumbnail --cookies-from-browser firefox'
alias ssh='TERM=xterm-256color command ssh'
alias ds='dsh web --no-open'
alias lg='lazygit'
alias gd='git diff'
alias ga='git add .'
alias gc='git commit -am'
alias gl='git log'
alias gs='git status'
alias gst='git stash'
alias gsp='git stash pop'
alias gp='git push'
alias gpl='git pull'
alias gsw='git switch'
alias gsm='git switch main'
alias gb='git branch'
alias gbd='git branch -d'
alias gco='git checkout'
alias gsh='git show'

function nvim-lab() {
    env NVIM_APPNAME=nvim-lab nvim "$@"
}

# 复用现有的 kind 启停流程。
function kup() {
    fish --no-config -c 'source ~/.config/fish/functions/kup.fish; kup $argv' -- "$@"
}

function kdown() {
    fish --no-config -c 'source ~/.config/fish/functions/kdown.fish; kdown $argv' -- "$@"
}

for completion_command in kubectl kind; do
    if (( $+commands[$completion_command] )); then
        source <("$completion_command" completion zsh)
    fi
done
unset completion_command

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh --cmd cd)"
fi
if (( $+commands[direnv] )); then
    eval "$(direnv hook zsh)"
fi
if [[ -o interactive && -t 1 ]] && (( $+commands[fastfetch] )); then
    fastfetch --key-padding-left 5
fi

# 加载 zsh-autosuggestions (如果存在)
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# 激活 Starship 提示符 
if command -v starship >/dev/null; then
    add-zsh-hook -D precmd 'prompt_grml*_precmd'
    eval "$(starship init zsh)"
fi

# foot 用 OSC 133 标记提示符，方便在历史输出中跳转。
if [[ $TERM == foot* ]]; then
    autoload -Uz add-zsh-hook
    function mark_prompt_start() {
        printf '\033]133;A\033\\'
    }
    add-zsh-hook precmd mark_prompt_start
fi

# 加载 zsh-syntax-highlighting (必须是文件的最后一行加载)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
