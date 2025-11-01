function fish_user_key_bindings

    set -g fish_key_bindings fish_vi_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert

    set -g fish_cursor_end_mode exclusive

    # fzf
    bind \cf fzf_change_directory
    bind -M insert \cf fzf_change_directory
    #bind -M insert \ch __fzf_tldr
    bind \ch __fzf_tldr

    bind -M insert alt-d diff_files_fzf
    bind alt-d diff_files_fzf

    bind -M visual -m default y 'fish_clipboard_copy; commandline -f end-selection repaint-mode'
    bind yy fish_clipboard_copy
    # bind p fish_clipboard_paste
    bind p 'set -g fish_cursor_end_mode exclusive' forward-char 'set -g fish_cursor_end_mode inclusive' fish_clipboard_paste

    # bind \cr _atuin_search
    # bind -M insert \cr _atuin_search
end
