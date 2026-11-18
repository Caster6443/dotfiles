function fish_greeting
    if string match -qir '(^|:)hyprland(:|$)' -- "$XDG_CURRENT_DESKTOP"
        echo -ne '\x1b[38;5;16m'
    else
        set_color --bold brcyan
    end
    echo '     ______           __          __  _       '
    echo '    / ____/___ ____  / /__  _____/ /_(_)___ _ '
    echo '   / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/ '
    echo '  / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /  '
    echo '  \____/\__,_/\___/_/\___/____/\__/_/\__,_/   '
    set_color normal
    fastfetch --key-padding-left 5
end
