function _fzf_change_directory
  fzf | perl -pe 's/([ ()])/\\\\$1/g'|read foo
  if [ $foo ]
    builtin cd $foo
    commandline -r ''
    commandline -f repaint
  else
    commandline ''
  end
end

function fzf_change_directory
  begin
    # Define a sed pattern to remove ANSI color codes
    set -l remove_ansi '\x1B\[[0-9;]*[mK]'
    
    echo $HOME/.config

    find $(ghq root) -maxdepth 4 -type d -name .git | sed 's/\/\.git//'

    ls --color=never -ad */ | sed -r "s/$remove_ansi//g" | perl -pe "s#^#$PWD/#" | grep -v \.git 

    ls --color=never -d $HOME/clones/*/ | sed -r "s/$remove_ansi//g" | grep -v \.git 

    ls --color=never -d $HOME/workplace/*/ | sed -r "s/$remove_ansi//g" | grep -v \.git 
  end | sed -e 's/\/$//' | awk '!a[$0]++' | _fzf_change_directory $argv
end
