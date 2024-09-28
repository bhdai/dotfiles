# run python script with timing
function pytime
  set start (date +%s.%N)
  python $argv
  set end (date +%s.%N)
  set runtime (echo "$end - $start" | bc -l)
  printf "Runtime: %.6f seconds\n" $runtime
end
