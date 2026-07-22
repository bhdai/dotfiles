set -g __dot_repo ~/ghq/github.com/bhdai/dotfiles

# Files deployed by copy rather than symlink: they are root-owned and read by
# root daemons, so pointing them at a user-writable home directory would let
# anyone who can write $HOME change what root parses. Deploying stays manual
# (see README); `dot status` only reads them to report drift.
set -g __dot_system_src system/keyd/default.conf system/zapret/config system/zapret/zapret-hosts-user.txt
set -g __dot_system_dest /etc/keyd/default.conf /opt/zapret/config /opt/zapret/ipset/zapret-hosts-user.txt

function _dot_color -a name
    isatty stdout; or return
    switch $name
        case linked synced
            set_color green
        case missing
            set_color yellow
        case conflict wrong drifted absent
            set_color red
        case reset
            set_color normal
        case dim
            set_color brblack
    end
end

function _dot_row -a state name note
    _dot_color $state
    printf '  %-10s' $state
    _dot_color reset
    if test -n "$note"
        printf '%-15s' $name
        _dot_color dim
        printf '%s' $note
        _dot_color reset
    else
        printf '%s' $name
    end
    echo
end

# One of: linked, missing, conflict, wrong. `wrong` also yields the current
# target as a second line so callers can report where it actually points.
function _dot_state -a name
    set -l src $__dot_repo/config/$name
    set -l dest ~/.config/$name

    if test -L $dest
        set -l target (readlink $dest | string trim -r -c /)
        if test "$target" = "$src"
            echo linked
        else
            echo wrong
            echo $target
        end
    else if test -e $dest
        echo conflict
    else
        echo missing
    end
end

function _dot_link -a name
    set -l src $__dot_repo/config/$name
    set -l dest ~/.config/$name

    if not test -e $src
        _dot_row missing $name "no such entry in config/"
        return 1
    end

    set -l state (_dot_state $name)
    switch $state[1]
        case linked
            return 0
        case conflict
            _dot_row conflict $name "not a symlink, run: dot add $name"
            return 1
        case wrong missing
            ln -sfn $src $dest
            _dot_row linked $name
            return 0
    end
end

function _dot_link_all
    set -l failed 0
    for item in $__dot_repo/config/*
        _dot_link (basename $item); or set failed (math $failed + 1)
    end
    test $failed -eq 0
end

function _dot_add -a name
    set -l src $__dot_repo/config/$name
    set -l dest ~/.config/$name

    if test -e $src
        echo "config/$name already exists in the repo"
        return 1
    end
    if not test -e $dest
        echo "$dest does not exist"
        return 1
    end
    if test -L $dest
        echo "$dest is already a symlink"
        return 1
    end

    mv $dest $src
    ln -sfn $src $dest
    _dot_row linked $name "moved into config/"
    _dot_color dim
    echo "  untracked until you run: git add config/$name"
    _dot_color reset
end

function _dot_del -a name
    set -l src $__dot_repo/config/$name
    set -l dest ~/.config/$name

    if not test -e $src
        echo "config/$name does not exist"
        return 1
    end
    if not test -L $dest
        echo "$dest is not a symlink"
        return 1
    end

    rm $dest
    mv $src $dest
    _dot_row missing $name "moved back to ~/.config"

    if git -C $__dot_repo ls-files --error-unmatch config/$name >/dev/null 2>&1
        _dot_color dim
        echo "  still tracked by git. to finish:"
        echo "    git -C $__dot_repo rm -r --cached config/$name"
        _dot_color reset
    end
end

function _dot_status
    set -l counts_linked 0
    set -l counts_missing 0
    set -l counts_problem 0

    echo config
    for item in $__dot_repo/config/*
        set -l name (basename $item)
        set -l state (_dot_state $name)
        switch $state[1]
            case linked
                _dot_row linked $name
                set counts_linked (math $counts_linked + 1)
            case missing
                _dot_row missing $name
                set counts_missing (math $counts_missing + 1)
            case conflict
                _dot_row conflict $name "not a symlink"
                set counts_problem (math $counts_problem + 1)
            case wrong
                _dot_row wrong $name "-> $state[2]"
                set counts_problem (math $counts_problem + 1)
        end
    end

    echo
    echo system
    for i in (seq (count $__dot_system_src))
        set -l src $__dot_repo/$__dot_system_src[$i]
        set -l dest $__dot_system_dest[$i]
        set -l label (string replace 'system/' '' $__dot_system_src[$i])

        if not test -e $dest
            _dot_row absent $label "not deployed"
            set counts_problem (math $counts_problem + 1)
        else if not test -r $dest
            _dot_row absent $label "not readable"
        else if diff -q $src $dest >/dev/null 2>&1
            _dot_row synced $label
        else
            set -l n (diff $src $dest | string match -r '^[<>]' | count)
            _dot_row drifted $label "$n lines differ"
            set counts_problem (math $counts_problem + 1)
        end
    end

    echo
    printf '  %d linked' $counts_linked
    test $counts_missing -gt 0; and printf ', %d missing' $counts_missing
    test $counts_problem -gt 0; and printf ', %d need attention' $counts_problem
    echo
end

function _dot_help
    echo "Usage: dot <command> [name ...]"
    echo
    echo "Commands:"
    echo "  status          Show link state of every config/ entry and system/ file"
    echo "  link <name>...  Symlink config/<name> to ~/.config/<name>"
    echo "  link all        Link every entry in config/"
    echo "  add <name>      Move ~/.config/<name> into config/ and link it back"
    echo "  del <name>      Unlink and move config/<name> back to ~/.config"
    echo
    echo "Never runs git. Deploying system/ stays manual; see README."
end

function dot -a cmd
    switch "$cmd"
        case status
            _dot_status
        case link
            if test (count $argv) -lt 2
                _dot_help
                return 1
            else if test "$argv[2]" = all
                _dot_link_all
            else
                set -l failed 0
                for name in $argv[2..-1]
                    _dot_link $name; or set failed (math $failed + 1)
                end
                test $failed -eq 0
            end
        case add del
            if test (count $argv) -ne 2
                _dot_help
                return 1
            end
            _dot_$cmd $argv[2]
        case '*'
            _dot_help
            return 1
    end
end
