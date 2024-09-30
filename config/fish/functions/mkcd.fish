# create a new directory and immediately cd to it
function mkcd
  mkdir -vp $argv && cd $argv
  echo "cd: Change directory to '$argv'"
end
