# No --color options: fzf's defaults are drawn from the terminal's 16 ANSI colours,
# so it follows whatever theme ghostty is set to instead of pinning one scheme.
#
# Set before the interactive guard because non-interactive shells need it too:
# `bind-key T` runs `fish -c tm` inside a tmux popup, and a shell that skipped this
# would fall back to whatever FZF_DEFAULT_OPTS the tmux server captured when it
# started -- which is how a theme removed from this file kept showing up there.
set -x FZF_DEFAULT_OPTS "
  --cycle
  --layout=reverse
  --height 60%
  --ansi
  --preview-window=right:70%
  --bind=ctrl-u:half-page-up,ctrl-d:half-page-down,ctrl-x:jump
  --bind=ctrl-f:preview-page-down,ctrl-b:preview-page-up
  --bind=ctrl-a:beginning-of-line,ctrl-e:end-of-line
  --bind=ctrl-j:down,ctrl-k:up
"

status is-interactive; or exit

bind -M insert \ch __fzf_tldr

set fzf_diff_highlighter delta --paging=never --width=20
fzf_configure_bindings \
    --directory=\ct \
    --git_log=\cg \
    --git_status=\cs \
    --history= \
    --processes=\cp \
    --variables=
