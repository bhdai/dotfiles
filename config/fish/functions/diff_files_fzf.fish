function diff_files_fzf
    if test $PWD = $HOME
        echo "Error: Cannot run diff_files_fzf in home directory"
        return 1
    end

    set -l files (fd -t f -H -E .git . | fzf --multi --height=40% --layout=reverse --info=inline --prompt="Select two files to diff (or one file to diff with clipboard) > ")

    set -l file_count (count $files)

    if test $file_count -eq 1
        diff -u "$files[1]" (wl-paste --primary | psub) | delta
    else if test $file_count -eq 2
        diff -u "$files[1]" "$files[2]" | delta
    end

    commandline -r ''
    commandline -f repaint
end
