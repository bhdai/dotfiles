function tm
    set -l search_dir "$HOME/ghq/github.com"

    # Check if directory exists
    if not test -d $search_dir
        echo "Directory $search_dir does not exist."
        return 1
    end

    # 1. Get running session paths (based on the active pane in each session)
    set -l running_paths
    if type -q tmux
        set running_paths (tmux list-sessions -F "#{pane_current_path}" 2>/dev/null)
    end

    # 2. Generate the list
    set -l project_dir (begin
        # Process running sessions first
        for p in $running_paths
            # Only process if path is inside our search directory
            if string match -q "$search_dir*" "$p"
                # Remove the base search_dir from the path to get "user/repo/subdir..."
                set -l rel_path (string replace "$search_dir/" "" "$p")
                
                # Split path by '/' to inspect components
                set -l parts (string split "/" $rel_path)
                
                # We need at least 2 parts (user/repo) to form a valid project root
                if test (count $parts) -ge 2
                    # Reconstruct exactly "$search_dir/user/repo"
                    echo "$search_dir/$parts[1]/$parts[2]"
                end
            end
        end
        # List all available projects
        find $search_dir -mindepth 2 -maxdepth 2 -type d
    end | awk '!seen[$0]++' | fzf)

    # Exit if no selection made
    if test -z "$project_dir"
        return 0
    end

    # Extract directory name (e.g., "RAGitect")
    set -l project_name (basename "$project_dir")

    # Sanitize session name: lowercase and replace dots with underscores
    set -l session_name (string lower "$project_name" | string replace -a "." "_")

    # Check if session exists; if not, create it with the 3-window layout
    if not tmux has-session -t="$session_name" 2>/dev/null
        # 1. Create session detached
        tmux new-session -d -s "$session_name" -c "$project_dir"
        
        # 2. Run nvim in the first window (the one just created)
        #    Using :^ makes it target the first window of the session regardless of index
        tmux send-keys -t "$session_name:^" "nvim ." C-m
        
        # 3. Create 2nd and 3rd windows
        tmux new-window -t "$session_name" -c "$project_dir"
        tmux new-window -t "$session_name" -c "$project_dir"
        
        # 4. Focus back on the first window (neovim)
        tmux select-window -t "$session_name:^"
    end

    # Switch logic
    if set -q TMUX
        tmux switch-client -t "$session_name"
    else
        tmux attach-session -t "$session_name"
    end
end