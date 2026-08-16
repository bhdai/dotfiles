# attention

Tells you which tmux pane wants you when you are not looking at it, and what every
agent under tmux is doing right now.

Two situations motivated this. A `pacman -Syu` that stops on `[Y/n]` in a window you
switched away from, and a Claude or Codex session that finished — or is waiting for
an approval — while you are reading a diff in another pane. Both are the same
problem: something in a pane you cannot see is blocked on you. Only the detection
differs, so detection is pluggable and everything downstream is shared.

## Two axes

A pane carries two independent states, because "does this want me" and "what is it
doing" are different questions and answering both with one field makes both worse.

The **attention** axis is transient. It says the pane wants you *now*, and visiting
the pane is the acknowledgement that retires it:

| State | Means | Surfaces |
|---|---|---|
| `blocked` | You are the bottleneck, right now | status line, `prefix+s`, desktop notification |
| `done` | An agent finished its turn; reviewable whenever | status line, `prefix+s` |
| `error` | A long command failed | status line, `prefix+s` |

The **agent** axis is durable. It says what the agent in the pane is doing, and only
that agent's own lifecycle events change it — an agent is working whether or not you
are watching, so looking at the pane must not clear it:

| State | Means | Surfaces |
|---|---|---|
| `waiting` | Wants an answer — a permission, or a prompt | `prefix+s` |
| `working` | Mid-turn | `prefix+s` |
| `idle` | Alive, turn finished, nothing pending | `prefix+s` |

Only `blocked` notifies. `done` on ten agents firing ten popups while you read
Reddit is exactly the noise that gets a notification system muted, and the status
line is already a persistent reminder. The agent axis never notifies at all: it is a
readout, and everything in it worth interrupting you for has already arrived as
`blocked`.

Rollups on window and session lines show the highest-severity state below them, per
axis. `blocked` outranks `error` because a failure will still be there in five
minutes; `waiting` outranks `working` for the same reason.

**The status line carries the attention axis only.** The state recolours the window
entry — red, yellow, green — rather than adding a glyph, so the bar keeps one visual
vocabulary. Bold goes on meaning "current window"; colour means state, and the two
cannot collide in practice since a window you are looking at has its state cleared
within a second. There is no room for a count, so a window with two blocked panes
looks like one with a single blocked pane.

The agent axis is deliberately kept off the bar. It never clears, so putting it there
would mean a permanent marker on every window that has ever run an agent — the bar
would stop being a thing you notice changing, which is the only reason it works.

**`prefix+s` carries both**, with counts. The two axes are kept apart by shape,
because a waiting agent is `blocked` and `waiting` in the same moment and one glyph
serving both would read as a single marker drawn twice:

| | Attention | Agent |
|---|---|---|
| wants you | `◉` blocked, red | `✻` waiting, yellow |
| in progress | | `✻` working, blue, breathing |
| finished | status line only | `✻` idle, green |
| failed | `▲` error, yellow | |

`done` is the one state that draws no glyph here. It has exactly one writer — an
agent finishing its turn — which is the same event that sets the agent axis to
`idle`, so drawing both put two markers on the row for one thing. The agent axis
wins that tie because it is the durable half: it survives the visit that clears
`done`, and it is still there when you come back. The status line keeps `done`,
where it is not a duplicate of anything, and remains the thing that tells you a turn
finished in a window you are not looking at.

What that costs is the distinction between "finished and unreviewed" and "finished
an hour ago", which only `done` tracks. That distinction is on the bar, and one
glyph per pane is worth more in a tree you scan than a second one that means almost
the same thing.

`blocked` and `waiting` do still land together, red beside yellow, because there
they mean different things: `waiting` is what the agent is doing, `blocked` is that
you have not answered it yet. Only `error` breaks the dot vocabulary, because a
failed command is not a degree of the same thing.

The agent axis is one glyph in three colours instead. A pane running an agent is a
single thing whose condition changes, not three different things, and `✻` is the
mark the agents themselves show while thinking — so the column reads without a
legend, and the state is the colour: green finished, yellow wants an answer, a blue
pulse mid-turn. Yellow is `error` on the other axis, which is a collision only in
the abstract: the shapes differ and both halves sit on the same row, where the
question is which glyph is lit, not which hue appeared somewhere.

Sessions stay collapsed, so the session rollup is what makes an agent visible without
expanding the tree.

### The working pulse

`working` breathes through `· ✢ ✳ ∗ ✻ ✽` and back down, at 150ms a frame, so a
running turn is distinguishable from one that died mid-tool-call without waiting for
the liveness check to notice. A stalled agent and a busy one are the same static
glyph otherwise, and telling them apart is most of why you open the tree at all.

Size and brightness move together — the frames carry their own colour, dim at `·`
and near-white at `✽`, overriding the marker's blue. One channel alone reads as a
flicker at this size; two make it read as one mark pulsing rather than as a glyph
being swapped for a different glyph. The sequence runs back down instead of
restarting at `·`, because the jump from the largest frame to the smallest is a pop
that draws the eye more than the motion does.

The frame is a global option, `@att_spin`, that `attentiond` advances. tmux
re-evaluates an open mode's format on every option write — a counter written 40 times
at 200ms rendered 39 distinct frames in `choose-tree` with no `refresh-client` at
all — so the option is the whole channel. `refresh-client -S` is not involved and
would not help: it redraws the status line, which deliberately reads none of this.

Frames are written only while a pane is in `tree-mode`. Nothing else draws the agent
axis, so an agent working with nobody watching would be writing frames forever for a
marker on no screen — and a frame is not free. An option write marks the client for
redraw whatever its scope: pane, session and global writes each measured around four
status-line repaints on 3.7, so seven frames a second is around thirty repaints a
second of a bar that did not change. For the seconds a tree is open that is
invisible. Left running it would be a repaint storm nobody asked for.

That gate is checked between frames rather than on the once-a-second pane scan,
which is the difference between an animation and one you keep missing: a second of
static glyph is most of the time anyone spends in a tree, so sampling it at the tick
meant the pulse usually started around when you closed the thing. Polling it at
frame rate is affordable for the same reason writing at frame rate is not — a
`list-panes` read costs a fork, while a write costs every attached client a redraw —
and it only runs at all while some agent is mid-turn.

`@att_spin` is defined in `tmux.conf` as a plain `✻`, and the daemon parks it back
there when it stops animating and on startup. A stopped daemon, or a crash on the
smallest frame, then degrades to a static mark rather than to a bare dot or an
empty column.

## Sources, and who owns a pane

`@att_owner` records which source made a claim. `attentiond` overwrites only what it
owns itself, so a hook's state survives the next poll. Without this the poller would
clobber every agent state one second after it was set, because an agent pane looks
idle to the poller by design.

- **`poll`** — `attentiond`, once a second, for `blocked` on ordinary commands.
- **`hook`** — Claude Code and Codex lifecycle events, via `attention-hook`.
  A crashed agent never fires `SessionEnd`, so its claim lapses when no `claude` or
  `codex` process is alive on the pane's tty. Liveness rather than a timeout: a long
  block you simply have not returned to yet must not expire.
- **`shell`** — a fish `fish_postexec` handler, for `error`.

The agent axis has one writer, `attention-hook`, so it needs no owner field — but it
does need the same liveness lapse, and for a stronger reason. Clear-on-visit cannot
retire it, so a crashed agent's `working` would otherwise sit there forever. That
check runs every fifth tick rather than every one: it costs two `pgrep`s per agent
pane, and a dead agent's marker lingering four seconds is invisible.

For the same reason `attentiond`'s startup sweep clears the attention axis and both
sets of rollups but leaves per-pane agent state alone. It is the one thing here the
daemon does not author, and wiping it on restart would blank a live agent's marker
until its next event — which for an idle one is whenever you next type. Anything
stale is a dead agent, and the liveness check takes it within five seconds.

## How a blocked pane is recognised

The poller has no event to listen for, so it observes. Nothing looks at the prompt
text — `[Y/n]`, `[y/N]` and pacman's `::` are all the same case. Every candidate pane
must first be **off the alternate screen**; then either path below marks it blocked.

**Path 1 — something in the foreground process group is parked in `wait_woken`.**
Immediate, no timer. Catches anything that blocks in `read()`: pacman, sudo, git,
ssh, and shell `read` builtins, whether the prompt takes Enter or a single keypress.

**Path 2 — the group has stopped writing while the cursor sits mid-line.** For
programs Path 1 structurally cannot see.

| Pane | alt | wchan | cursor_x | group `wchar` | |
|---|---|---|---|---|---|
| `[y/N]` with Enter | 0 | `wait_woken` | | | **blocked** (1) |
| `[y/N]` single key | 0 | `wait_woken` | | | **blocked** (1) |
| `read -s` (password) | 0 | `wait_woken` | | | **blocked** (1) |
| **`yay` at its prompt** | 0 | `futex_do_wait` | **36** | **static** | **blocked** (2) |
| `yay` downloading | 0 | `futex_do_wait` | >0 | **growing** | — |
| server, logged a line | 0 | `ep_poll` | **0** | static | — |
| half-typed command | 0 | — | 27 | static | — (group is all shell) |
| `sleep 300` | 0 | `hrtimer_nanosleep` | 0 | static | — |
| idle bash / sh / fish | 0 | `poll_schedule_timeout` | 0 | static | — |
| `less` | **1** | `wait_woken` | | | — |
| btop, nvim, claude | **1** | `do_epoll_wait` | | | — |

- **`n_tty_read` never appears.** Everything modern epolls stdin rather than blocking
  in `read()`, so a rule matching that symbol would never fire. The symbol a genuine
  blocking read parks on is `wait_woken`.
- **wchan cannot see a Go program's blocked read at all.** `yay` at a prompt has no
  thread in `wait_woken` — all thirteen sit in `futex_do_wait` or `do_epoll_wait`,
  because the reading goroutine parks in the netpoller and no OS thread is in a read
  syscall. Scanning threads does not help and actively hurts: fzf *does* have a
  `wait_woken` thread. This is why Path 2 exists, and why it is not optional — `yay`
  is the case the whole thing was built for.
- **The alternate screen separates a prompt from a pager.** `less` really does block
  in a tty read and is indistinguishable from a confirmation by wchan alone, but it
  switches to the alternate screen first and tmux tracks that in `#{alternate_on}`.
- **Path 2's guards each kill a specific false positive.** `cursor_x > 0` drops the
  idle server, which logged a line ending in a newline and left the cursor at column
  0. Requiring a live non-shell process in the group drops the half-typed command
  line you walked away from. And reading `wchar` from `/proc/<pid>/io` rather than
  timing output is what keeps an in-place progress bar — same cursor, same screen
  line, but bytes still flowing — from reading as silence.
- **Zombies must be skipped, or every fish prompt looks blocked.** atuin leaves an
  unreaped child in the foreground group after each command, and a dead process
  counted as a running command turns an ordinary prompt — cursor after the `❯`,
  nothing being written — into a Path 2 match. It re-armed on every visit, so
  leaving the pane notified again each time.
- **Canonical mode was the obvious clause and is the wrong one.** It is true of a
  busy `sleep` that never touched termios, and false of a single-keypress `[y/N]`.

A consequence worth knowing: **an fzf left open in a pane you switched away from
counts as blocked**, via Path 2. That is arguably correct — it is waiting for you —
and while you are looking at it, clear-on-visit suppresses it.

Two further traps, both of which produced silent false negatives during the build:

- `#{pane_current_command}` reports the pane's *shell* even while another process
  owns the terminal. The foreground pgid comes from `/proc/<pane_pid>/stat` instead.
- That pgid is the process group *leader*, which is not necessarily the reader: a
  shell invoked without job control (`fish -c 'pacman ...'`) leaves its child in its
  own process group, so the leader sits in `futex_do_wait` while the child two pids
  along is the one parked in the read. The whole group is scanned.

A `blocked` reading must survive two consecutive samples before it counts, but a
single unblocked sample clears it. Slow to alarm, fast to calm: the two-second delay
is invisible when you are away, and it prevents a short canonical read mid-pipeline
from flickering the status line.

Fish's own `read` builtin runs the tty raw, so fish-native prompts are not detected.
That is the correct trade: they have full line editing and are not what this is for.

## Notifications

`notify-send` into the Quickshell daemon, which advertises `actionsSupported`, so
the body is clickable and jumps to the pane. The jump finds the terminal window by
walking the tmux client's ppid chain until a pid matches a Hyprland window — matching
on window class alone would pick an arbitrary Ghostty when several are open.

It works from any workspace, and from any other window: tmux has no idea Hyprland
exists, so the pane stays `blocked` regardless of what is on screen, and focusing a
window on another workspace switches to that workspace as a side effect — no separate
workspace dispatch is needed.

Hyprland 0.56 dispatches through Lua, so the focus call is
`hl.dsp.focus({ window = "address:0x..." })`. The shell forms that every guide still
shows — `focuswindow address:...` and `focuswindow,address:...` — are **parse errors**
on this version, not no-ops. They fail silently inside a background notifier, which
is exactly where nobody sees the error.

Suppressed when you are already looking at the pane, using the same test `done.fish`
applies: the pane is current in an attached session *and* the terminal showing that
client holds the compositor's focus.

Fired once per blocked episode. Claude re-fires `Notification` about every minute
while it sits idle, and repeating an interrupt you have already chosen to ignore is
how this ends up muted.

## Agent wiring

Claude Code and Codex share a hook payload shape and config schema, so one script
serves both. They do not share the whole event vocabulary — Codex has no `Stop` and
no `Notification` — so two events arrive by other routes:

| | Claude | Codex |
|---|---|---|
| `blocked` + `waiting` | `Notification` | `PermissionRequest`, declared `async` |
| `done` + `idle` | `Stop` | `notify` program (`agent-turn-complete`) |
| clear + `working` | `UserPromptSubmit` | same |
| `working` (resumed) | `PostToolUse` | same, declared `async` |
| clear both | `SessionEnd` | same |
| pane mapping + `idle` | `SessionStart` | same |

`PostToolUse` is there because neither agent announces "resumed after you approved".
Without it a pane you answered at a permission prompt reads `waiting` for the rest of
the turn, which is the exact lie the durable axis exists to avoid; a tool that has
just finished running is the available proof that the agent is going again. It is the
only hook here that fires on a hot path, so it costs a `bash` and a `jq` per tool
call, and `attention-set` reads the current value and returns without writing when it
is unchanged — which is every call but the first after an approval. Otherwise every
tool call would cost tmux a status-line redraw.

`PermissionRequest` is a decision hook — stray stdout there is read as a verdict on
the tool call, and Codex has a literal "denied approval" path. It is used for Codex
only because nothing else is available, declared `async` so it can never delay or
deny a tool call, and `attention-hook` always exits 0 and prints nothing. Claude has
`Notification` and so leaves `PermissionRequest` untouched.

`Notification` also fires when Claude has been idle waiting for input, not only for
permission. That is wanted: it is `blocked` by the definition above.

Subagent events are ignored. A subagent finishing is an internal step of a turn that
is still running, and surfacing it would flicker a pane `done` repeatedly.

Hooks are not guaranteed to be direct children of the pane, so `TMUX_PANE` is not
trusted on its own: the session-to-pane mapping is recorded at `SessionStart`, where
the environment is known-fresh, and is the source of truth afterwards. Outside tmux
the hook is a silent no-op.

## Deploy

Run from the repo root. `attention/` is not under `config/`, so `dot` does not
manage it; the fish handler and the tmux formats live in their own modules and are
deployed with them.

```bash
mkdir -p ~/.config/systemd/user
ln -sfn ~/ghq/github.com/bhdai/dotfiles/attention/systemd/attentiond.service ~/.config/systemd/user/attentiond.service
systemctl --user daemon-reload
systemctl --user enable --now attentiond.service
```

The agent hooks come from `agentic/` (see its README): `claude/settings.json` and
`codex/hooks.json` are linked in with everything else. Codex's `notify` program has
to be set in `~/.codex/config.toml`, which is not symlinked because Codex rewrites
it:

```toml
notify = ["/home/dai/ghq/github.com/bhdai/dotfiles/attention/bin/attention-hook", "codex-notify"]
```

## Checking it works

```bash
tmux new-window 'bash -c "read -p \"[Y/n] \" x; sleep 60"'
tmux list-panes -a -F '#{pane_id} #{window_name} #{@att_state} #{@att_owner}'
```

The marker appears on the window in the status line within two seconds, the session
line in `prefix+s` carries the rollup, and a notification fires if the window is not
on screen. `systemctl --user status attentiond` for the daemon itself.

For the agent axis, watch a pane you are already running an agent in:

```bash
tmux list-panes -a -F '#{pane_id} #{@att_agent} #{@att_agent_kind}'
tmux list-windows -a -F '#{window_id} #{@att_agent_win}'
```

It should read `working` while a turn runs and stay there when you switch to the
pane, `waiting` at a permission prompt, and `idle` after the turn ends. Killing the
agent should clear it within five seconds. `prefix+s` shows the same thing.
