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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/the_monarch/miniconda3/bin/conda
    eval /home/the_monarch/miniconda3/bin/conda "shell.fish" hook $argv | source
else
    if test -f "/home/the_monarch/miniconda3/etc/fish/conf.d/conda.fish"
        . "/home/the_monarch/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH /home/the_monarch/miniconda3/bin $PATH
    end
end
# <<< conda initialize <<<
