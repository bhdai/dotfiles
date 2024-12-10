function _fzf_open_or_cd
    fzf | perl -pe 's/([ ()])/\\\\$1/g' | read -l result
    if test -n "$result"
        if test -f "$result"
            # if it's a file open it with neovim
            nvim "$result"
        else if test -d "$result"
            # if it a directory cd to it
            builtin cd "$result"
            commandline -r ''
            commandline -f repaint
        end
    else
        commandline ''
    end
end

function fzf_change_directory
    begin
        echo $HOME/.config

        find (ghq root) -maxdepth 4 \( -type d -name .git -prune \) -o \( -type f -o -type d \) | sed 's/\/\.git//'

        # use find to list both files and directories in current directory and subdirectories
        find . \( -type f -o -type d \) | sed -r "s#^\./##" | perl -pe "s#^#$PWD/#" | grep -v '\.git'

        find $HOME/Downloads -maxdepth 1 \( -type f -o -type d \) | grep -v '\.git'

        find $HOME/.config -maxdepth 1 \( -type f -o -type d \) | grep -v '\.git'

        find $HOME/ghq/github.com/buidai123/dotfiles/config/ -maxdepth 1 \( -type f -o -type d \) | grep -v '\.git'

        find $HOME/workplace -maxdepth 2 \( -type f -o -type d \) | grep -v '\.git'
    end | sed -e 's/\/$//' | awk '!a[$0]++' | _fzf_open_or_cd $argv
end
