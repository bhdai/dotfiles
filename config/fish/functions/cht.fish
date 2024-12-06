function cht
    set langs python c cpp kotlin lua bash fish css html tmux javascript typescript
    set commands fd rg man tldr awk xargs sed cp tr ls kill ssh git cat docker chmod chown pacman yay curl

    set options $langs $commands

    set selected (printf '%s\n' $options | fzf) # use fzf for faster selecting

    if test -z "$selected"
        echo "No selection made. Exiting."
        return
    end

    # prompt for the query
    read -P "Enter query: " query

    set query (string replace -a ' ' + $query)

    # construct the cht.sh url
    set url "cht.sh/$selected/$query"

    curl -s $url | vimpager # need to have vimpager for this to work. See vimpager in config.fish and in neovim core.utils.general.colorrize
end
