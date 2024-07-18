set -x PATH $PATH /usr/local/go/bin $HOME/go/bin

set -x GHQ_ROOT $HOME/ghq

alias g='cd (ghq root)/(ghq list | peco)'
alias gh='hub browse (ghq list | peco | cut -d "/" -f 2,3)'
