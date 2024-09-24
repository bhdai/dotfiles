function update --description 'Update tldr, tmux, fish'
    ~
    and echo "[update] tldr"
    and command tldr -u

    and echo "[update] tmux"
    and tmux_update

    and echo "[update] fish"
    # and fisher update
    and fish_update_completions
end
