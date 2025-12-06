# Cursor styles
set -gx fish_vi_force_cursor 1
set -gx fish_cursor_default block
set -gx fish_cursor_insert line blink
set -gx fish_cursor_visual block
set -gx fish_cursor_replace_one underscore
#set -gx TERM tmux-256color

# aliases
alias .. 'cd ..'
alias ... 'cd ../..'
alias .3 'cd ../../..'
alias .4 'cd ../../../..'
alias .5 'cd ../../../../..'

# command -qv nvim && alias vim nvim

set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

# Path
fish_add_path ~/.local/bin
fish_add_path /usr/local/sbin
fish_add_path /opt/apache-spark/bin/
fish_add_path /opt/apache-spark/sbin/

# Go
set -x GOPATH ~/go
fish_add_path ~/go/bin

# Exports
set -x LESS -rF
set -x COMPOSE_DOCKER_CLI_BUILD 1
set -x MANPAGER "nvim +Man!"
set -x MANROFFOPT -c
set -x XDG_SCREENSHOTS_DIR ~/Pictures/Screenshots/

# Fish
set fish_emoji_width 2
alias ssh "TERM=xterm-256color command ssh"
alias mosh "TERM=xterm-256color command mosh"
alias codex "CODEX_HOME=$PWD/.codex command codex"

# better -h flag
abbr -a --position anywhere --set-cursor -- -h "-h 2>&1 | bat --plain --language=help"

# Tmux
# abbr t tmux
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
abbr ncdu "ncdu --color dark"

# Editor
abbr v nvim
alias lv "NVIM_APPNAME=nvim-profiles/lazyvim nvim"
alias vimpager 'nvim - -c "lua require(\'core.utils.general\').colorize()"'
alias bt "coredumpctl -1 gdb -A '-ex \"bt\" -q -batch' 2>/dev/null | awk '/Program terminated with signal/,0' | bat -l cpp --no-pager --style plain"

alias lazygit "TERM=xterm-256color command lazygit"
alias g git
abbr gg lazygit
abbr gl 'git l --color | devmoji --log --color | less -rXF'
abbr gs "git st"
abbr gb "git checkout -b"
abbr gc "git commit"
abbr gpr "git pr checkout"
abbr gm "git branch -l main | rg main > /dev/null 2>&1 && git checkout main || git checkout master"
abbr gcp "git commit -p"
abbr gpp "git push"
abbr gp "git pull"

# other
abbr ytop btm
abbr fda "fd -IH"
abbr rga "rg -uu"
# abbr grep rg
abbr weather "curl -s wttr.in/Hanoi | grep -v Follow"
abbr show-cursor "tput cnorm"
abbr hide-cursor "tput civis"
alias pkgInfo="pacman -Qq | fzf --preview 'pacman -Qil {} | bat -fpl yml' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"
alias discord "discord --use-gl=desktop"

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
abbr jf "journalctl --follow -n 100"
abbr jg "journalctl -b --grep"
abbr ju "journalctl --all --follow -n 100 --unit"
abbr juu "journalctl --all --follow -n 100 --user-unit"

# Docker
abbr lad lazydocker
abbr d docker
abbr dc docker compose
abbr dcu "docker compose up -d"
abbr dcd "docker compose down"
abbr dcl "docker compose logs -f"
abbr dps "docker ps"
abbr dpsa "docker ps -a"
abbr di "docker images"
abbr dex "docker exec -it"
abbr dl "docker logs -f"
abbr dprune "docker system prune -af"
abbr drm "docker rm -f"
abbr drmi "docker rmi"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/monarch/miniforge3/bin/conda
    eval /home/monarch/miniforge3/bin/conda "shell.fish" hook $argv | source
else
    if test -f "/home/monarch/miniforge3/etc/fish/conf.d/conda.fish"
        . "/home/monarch/miniforge3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH /home/monarch/miniforge3/bin $PATH
    end
end
# <<< conda initialize <<<

#nvm
set -gx nvm_default_version lts
