# compile and run c/c++ program
function crun
  set red (set_color red)
  set filename (basename $argv[1] .c)
  set compiler gcc
  set compile_flags
  set run_args
  set cyan (set_color cyan)
  set green (set_color green)
  set normal (set_color normal)
  set source_file $argv[1]

  if test (string match -r '\.cpp$' $argv[1])
    set compiler g++
    set filename (basename $argv[1] .cpp)
  end

  # Remove the source file from argv
  set -e argv[1]

  # Parse remaining arguments
  for arg in $argv
    switch $arg
      case '-omp'
        set -a compile_flags '-fopenmp'
      case '-*'
        set -a compile_flags $arg
      case '*'
        set -a run_args $arg
    end
  end

  # Compile
  set compile_cmd $compiler -o $filename $source_file $compile_flags
  echo $cyan"[crun] Compiling with: $compile_cmd"$normal
  eval $compile_cmd

  if test $status -eq 0
    echo $green"[crun] Compilation successful. Running the program:"$normal
    # Run
    set run_cmd ./$filename $run_args
    eval $run_cmd
    echo $cyan"[crun] Program execution completed."$normal
  else
    echo $red"[crun] Compilation failed."$normal
  end
end
