set fish_greeting ""

# set -gx TERM alacritty

set -gx TERM screen-256color

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


set -gx EDITOR nvim

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

if type -q eza
    alias ll "eza -l -g --icons"
    alias lla "ll -a"
end

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
    source $LOCAL_CONFIG
end

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
