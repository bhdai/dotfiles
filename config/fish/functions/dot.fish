function _dot_add -a name
    set -l src ~/ghq/github.com/bhdai/dotfiles/config/$name
    set -l dest ~/.config/$name

    # src should exist and be a file or a directory
    # dest should not exist
    if not test -f $dest -o -d $dest
        echo "$dest does not exist"
        return 1
    end

    if test -e $src
        echo "$src already exists"
        return 1
    end

    mv -v $dest $src
    ln -sv $src $dest
end

function _dot_del -a name
    # remove the symlink and move the directory back
    set -l src ~/ghq/github.com/bhdai/dotfiles/config/$name
    set -l dest ~/.config/$name

    if not test -e $src
        echo "$src does not exist"
        return 1
    end

    if not test -L $dest
        echo "$dest is not a symlink"
        return 1
    end

    rm -v $dest
    mv -v $src $dest
end

function _dot_link -a name
    set -l src ~/ghq/github.com/bhdai/dotfiles/config/$name
    set -l dest ~/.config/$name
    
    # Check if source exists in dotfiles repo
    if not test -e $src
        echo "❌ $src does not exist in dotfiles repo"
        return 1
    end
    
    # Check if destination is already correctly symlinked
    if test -L $dest
        set -l current_target (readlink $dest)
        if test "$current_target" = "$src"
            echo "⏭️  $name is already correctly linked"
            return 0
        else
            # Broken or incorrect symlink - remove and recreate
            echo "🔧 Fixing broken/incorrect symlink for $name"
            rm -v $dest
            ln -sv $src $dest
            return 0
        end
    end
    
    # Check if destination exists as a regular file/directory
    if test -e $dest
        echo "❌ $dest already exists as a regular file/directory (not a symlink)"
        echo "   Use 'dot add $name' if you want to move it to dotfiles repo"
        return 1
    end
    
    # Create the symlink
    echo "✅ Linking $name"
    ln -sv $src $dest
end

function _dot_link_all
    set -l dotfiles_dir ~/ghq/github.com/bhdai/dotfiles/config
    set -l success_count 0
    set -l skip_count 0
    set -l error_count 0
    
    echo "🔗 Linking all configs from dotfiles..."
    echo ""
    
    for item in $dotfiles_dir/*
        set -l name (basename $item)
        
        _dot_link $name
        set -l status $status
        
        if test $status -eq 0
            if string match -q "*already correctly linked*" (echo $_)
                set skip_count (math $skip_count + 1)
            else
                set success_count (math $success_count + 1)
            end
        else
            set error_count (math $error_count + 1)
        end
    end
    
    echo ""
    echo "📊 Summary:"
    echo "   ✅ Linked: $success_count"
    echo "   ⏭️  Skipped: $skip_count"
    echo "   ❌ Errors: $error_count"
end

function _dot_help
    echo "Usage: dot [add|del|link] <name> [name2 ...]"
    echo ""
    echo "Commands:"
    echo "  add <name>     Move config from ~/.config to dotfiles and create symlink"
    echo "  del <name>     Remove symlink and move config back to ~/.config"
    echo "  link <name>    Create symlink from dotfiles to ~/.config"
    echo "  link all       Create symlinks for all configs in dotfiles"
    echo ""
    echo "Examples:"
    echo "  dot link fish           # Link single config"
    echo "  dot link fish alacritty # Link multiple configs"
    echo "  dot link all            # Link all configs"
    return 1
end

function dot -a cmd
    if test (count $argv) -lt 2
        _dot_help
        return 1
    end
    
    switch $cmd
        case add
            _dot_add $argv[2]
        case del
            _dot_del $argv[2]
        case link
            # Handle 'dot link all'
            if test "$argv[2]" = "all"
                _dot_link_all
            else
                # Handle single or multiple link arguments
                for name in $argv[2..-1]
                    _dot_link $name
                end
            end
        case '*'
            _dot_help
            return 1
    end
end
