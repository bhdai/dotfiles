# Marks a pane whose long-running command failed, so the failure is still findable
# in prefix+s after done.fish's popup has expired -- done.fish notifies but keeps no
# state. Registered as a second fish_postexec handler rather than patched into the
# vendored plugin, and named to sort before it so it reads $status first.
#
# Part of the attention module; see attention/README.md.

if not status is-interactive
    exit
end

# Mirrors done.fish's threshold: a command short enough that you watched it finish
# does not need a marker left behind.
set -q __attention_min_duration; or set -g __attention_min_duration 5000

function __attention_ended --on-event fish_postexec
    set -l exit_status $status

    test -n "$TMUX_PANE"; or return
    test "$exit_status" -ne 0; or return
    test -n "$CMD_DURATION"; and test "$CMD_DURATION" -gt "$__attention_min_duration"; or return

    ~/ghq/github.com/bhdai/dotfiles/attention/bin/attention-set $TMUX_PANE error shell
end
