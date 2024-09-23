function fish_user_key_bindings

  set -g fish_key_bindings fish_vi_key_bindings
  fish_default_key_bindings -M insert
  fish_vi_key_bindings --no-erase insert

  # fzf
  bind \cf fzf_change_directory
  bind -M insert \ch __fzf_tldr

  bind -M visual -m default y 'fish_clipboard_copy; commandline -f end-selection repaint-mode'
  bind yy fish_clipboard_copy
  bind p fish_clipboard_paste
end
# fzf plugin
fzf_configure_bindings --directory=\co

fzf --fish | source
