# create a new directory and immediately cd to it
function mkcd
  mkdir -p $argv && cd $argv
end
