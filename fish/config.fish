set fish_greeting ""
# Cursor styles
set -gx fish_vi_force_cursor 1
set -gx fish_cursor_default block
set -gx fish_cursor_insert line blink
set -gx fish_cursor_visual block
set -gx fish_cursor_replace_one underscore
set -gx TERM tmux-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
# command -qv nvim && alias vim nvim

set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH


# Fish
set fish_emoji_width 2

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
    source $LOCAL_CONFIG
end

# Export
set -x MANPAGER "nvim +Man!"


# Tmux
abbr t tmux
abbr tc 'tmux attach'
abbr ta 'tmux attach -t'
abbr tad 'tmux attach -d -t'
abbr ts 'tmux new -s'
abbr tl 'tmux ls'
abbr tk 'tmux kill-session -t'
abbr tks 'tmux kill-server'
abbr tko 'tmux kill-session -a'

# Files & Directories
abbr mv "mv -iv"
abbr cp "cp -riv"
abbr mkdir "mkdir -vp"
alias ls="eza --color=always --icons --group-directories-first"
alias la 'eza --color=always --icons --group-directories-first --all'
alias ll 'eza --color=always --icons --group-directories-first --all --long'
abbr l ll

# Editor
abbr v nvim

alias lazygit "TERM=xterm-256color command lazygit"
abbr gg lazygit

# systemctl
abbr s systemctl
abbr su "systemctl --user"
abbr ss "command systemctl status"
abbr sl "systemctl --type service --state running"
abbr slu "systemctl --user --type service --state running"
abbr se "sudo systemctl enable --now"
abbr sd "sudo systemctl disable --now"
abbr sr "sudo systemctl restart"
abbr so "sudo systemctl stop"
abbr sa "sudo systemctl start"
abbr sf "systemctl --failed --all"

# journalctl
abbr jb "journalctl -b"
abbr jf "journalctl --follow"
abbr jg "journalctl -b --grep"
abbr ju "journalctl --unit"


starship init fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/monarch/miniconda3/bin/conda
    eval /home/monarch/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/monarch/miniconda3/etc/fish/conf.d/conda.fish"
        . "/home/monarch/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/monarch/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

