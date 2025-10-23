function _fzf_open_or_cd
    # fzf --preview 'sh -c '\''if [ -d "$1" ]; then eza --color=always --icons --group-directories-first "$1"; else bat --color=always --style=plain "$1"; fi'\'' sh {}' | read -l result
    fzf | read -l result
    if test -n "$result"
        if test -f "$result"
            # if it's a file open it with neovim
            nvim "$result"
        else if test -d "$result"
            # if it a directory cd to it
            builtin cd "$result"
        end
    end
    commandline -r ''
    commandline -f repaint
end

function fzf_change_directory
    # Check if current directory is not under /home
    if not string match -rq "^$HOME(/|\$)" $PWD
        echo "Error: Can only fzf within the /home directory."
        return 1
    end

    begin
        fd . $HOME -d 1 --type d --type f -H
        fd . $HOME/.config -d 1 --type d --type f -H
        fd . $HOME/Downloads -d 1 --type d --type f -H
        fd . $HOME/Documents/ -d 1 --type d --type f -H

        fd -t f -t d -H --exclude .git -E .cache -d 4 . (ghq root)
        fd -t f -t d -H --exclude .git -E .cache -d 2 . $HOME/workplace

        # for the current directory only search if it not the home directory(it's a pain though)
        if test $PWD != $HOME
            fd -t f -t d -H -E .git .
        end

    end | sed -e 's/\/$//' | awk '!a[$0]++' | _fzf_open_or_cd $argv
end
