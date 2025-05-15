function _fzf_open_or_cd
    fzf | perl -pe 's/([ ()])/\\\\$1/g' | read -l result
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
    if not string match -q "/home/*" $PWD
        echo "Error: Can only fzf within the /home directory."
        return 1
    end

    begin
        echo $HOME/.config

        find (ghq root) -maxdepth 4 \( -type d -name .git -prune \) -o \( -type f -o -type d \) | sed 's/\/\.git//'

        # for the current directory only search if it not the home directory(it's a pain though)
        if test $PWD != $HOME
            # use find to list both files and directories in current directory and subdirectories
            find . \( -type f -o -type d \) | sed -r "s#^\./##" | perl -pe "s#^#$PWD/#" | grep -v '\.git'
        end

        for dir in Documents Downloads
            find $HOME/$dir -maxdepth 1 \( -type f -o -type d \) | grep -v '\.git'
        end

        find $HOME/.config -maxdepth 1 \( -type f -o -type d \) | grep -v '\.git'

        find $HOME/ghq/github.com/bhdai/dotfiles/config/ -maxdepth 1 \( -type f -o -type d \) | grep -v '\.git'

        find $HOME/workplace -maxdepth 2 \( -type f -o -type d \) | grep -v '\.git'
    end | sed -e 's/\/$//' | awk '!a[$0]++' | _fzf_open_or_cd $argv
end
