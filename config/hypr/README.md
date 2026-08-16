# Session locking

`loginctl lock-session` is the single entry point. The keybind, the 300 s idle timeout
and pre-sleep all raise the same dbus lock event, so there is one lock command, one
fallback chain, and logind's `LockedHint` is set whichever path fired. Nothing invokes a
locker directly, and nothing calls `qs ipc call` and then suspends.

hypridle's `lock_cmd` asks Quickshell to lock and **matches the returned value**, not the
exit status. Measured on this machine: `qs ipc call` prints `Target not found.` and exits
**0** when the shell is alive but the lock module failed to load, and only exits 255 when
no instance is running at all — so exit status cannot tell that failure apart from
success. `grep -qx true` can.

`inhibit_sleep = 3` makes suspend wait for a compositor-confirmed session lock. `auto`
resolves to 1 here — hypridle picks between the two by detecting whether hyprlock is
launched before sleep, and this config's pre-sleep command is `loginctl lock-session` —
which would drop the inhibitor the moment `loginctl` returns, before anything is on
screen. Pinning to 3 closes that race at the cost of the lock/unlock hooks, which are
unused.

**hyprlock stays installed**, with `hyprlock.conf` and `/etc/pam.d/hyprlock` left alone.
It is the last link in `lock_cmd` for the one case where a fallback is real: the shell
already dead when the lock is *requested*, so nothing holds the lock yet and no
compositor flag is involved. Once Quickshell holds the lock, no second client can take it
over — see `../quickshell/docs/research/lock-client-death.md` for recovery from a session
left locked with no client.

Hyprland's session-lock restore (`misc:allow_session_lock_restore`) stays **off**. It
would let a new lock client adopt an existing lock, which is a way back into a locked
session rather than a way out of a dead one.

## One-time steps on a new machine

The PAM install line in [`system/pam.d`](../../system/pam.d/README.md), plus the avatar
the lock screen reads:

```bash
ln -sf ~/Pictures/profile/bird_profile.png ~/.face
```

`~/.face` is the convention SDDM, GDM and LightDM already read, so one file drives the
lock screen and any future display manager instead of letting them drift. Missing or
unreadable, the lock screen draws a themed `person` symbol rather than a broken image.

## Applying a change

`hypridle.conf` and `binds.lua` are read at startup, not watched:

```bash
pkill hypridle; setsid hypridle >/dev/null 2>&1 &   # autostarted by Hyprland, not a user unit
hyprctl reload                                      # picks up binds.lua
```

`hyprctl dispatch exec hypridle` does **not** work here — the Lua config parses the
dispatch argument as Lua and rejects the bare word.

Pulling the `config/quickshell` submodule does **not** reliably reload the running shell.
Observed on the cutover pull: the watcher fired part-way through the checkout, failed with
`module "qs.modules.lock" is not installed` because `shell.qml` had landed before the
module directory, and then went quiet — leaving the shell serving the *old* generation with
no sign anything was wrong. git also writes many files by rename, which this watcher
ignores. Force a clean reload by rewriting one file's contents in place, and confirm it took:

```bash
cd ~/.config/quickshell && cp shell.qml /tmp/s && cat /tmp/s > shell.qml
qs log | tail -5          # want a trailing "Configuration Loaded", not an error
qs ipc call lock isLocked # want "false", not "Target not found."
```

# Capture

`scripts/capture-region` is the only thing that asks *what* to capture; screenshots and OCR
are thin wrappers that decide what to do with the answer. Ported from
[Omarchy](https://github.com/basecamp/omarchy) (MIT), which replaces what grimblast was
doing here.

Two things happen before the picker appears, and both are the reason this is a script
rather than a bind:

- **The screen is frozen** with `hyprpicker -r -z`, and the freeze is deliberately *left
  running* across the handoff (`--keep-freeze` prints its PID for the caller to kill).
  grim must read the frozen overlay; killing the freeze first lets live content shift back
  in during teardown and land in the file.
- **Hardware cursors are forced on** for the duration of the grab. Where Hyprland falls
  back to software-composited cursors, the pointer is already in the framebuffer grim
  reads, so it appears in the shot no matter what grim is asked for.

Selection is one gesture: drag for a region, or click once and slurp snaps to the window
or monitor rectangle under the cursor, which is why `Print` alone replaced the old
copy/save × area/screen matrix. The shot goes to `~/Pictures` and the clipboard together.
While the picker is up it can be driven entirely from the keyboard — `Return` takes the
highlighted window, `Ctrl+Return` the whole screen, `Tab` and the arrows move the
highlight. Those binds are registered on `layer.opened` for slurp's `selection` namespace
and removed on `layer.closed`, so they exist only while a selection is on screen and
cannot collide with anything else here. Each handle is unbound individually; unbinding by
key would take this config's own `Return` and `Tab` bindings with it.

The editor is offered as a **notification action**, not run automatically — the shot is
already saved and copied, so the toast is an offer rather than a step. Omarchy carries the
click command in a private hint that only its own shell understands; Quickshell renders
real libnotify actions as buttons, so this uses one of those. The cost is that
`notify-send -A` blocks until the button is clicked, and Quickshell only *hides* a popup on
timeout while keeping the notification in its centre — nothing would ever close it for us.
Hence the `timeout 60` wrapper: it stops a waiter accumulating per screenshot, and doubles
as the window in which the button still works from the notification centre.

## Recording

`scripts/capture-screenrecording` is a toggle on `Alt+Print`, over the same picker —
`Shift` adds desktop audio, `Ctrl` adds the microphone too. Whichever chord started a
recording, any of them stops it. The soundtrack is chosen up front because it cannot be
added afterwards. Clicking a monitor in the picker records that whole monitor, so
full-screen recording needs no bind of its own.

Two flags differ from Omarchy's version and matter:

- **`-w region -region WxH+X+Y`**, not `-w WxH+X+Y`. gpu-screen-recorder 6 moved region
  geometry to its own flag; the old spelling is a v5 leftover and fails here.
- **A monitor is recorded by name** (`-w eDP-1`) when the selection turns out to be exactly
  one, which is what `--match-monitor` on the picker is for. Same capture backend, but no
  scaling arithmetic and native resolution.

Stopping is `SIGINT` — anything harsher leaves an unplayable file — and the recording is
then finalized before you are handed it. gpu-screen-recorder opens the encoder before
there is anything worth showing and PipeWire pops as the capture stream opens, so the
first 0.1s is trimmed, the first 400ms of audio is hard-muted (the pop is too close to
clipping for a fade to help), and the rest is normalized to -14 LUFS. The video is
stream-copied unless the first GOP actually contains warmup packets, since a stream copy
cannot drop those.

### Hooking up a bar indicator

`$XDG_RUNTIME_DIR/screenrecording-filename` holds the path being written, and exists for
exactly the lifetime of the recording. That is the seam: a Quickshell indicator watches
that one file rather than polling for the process, and the scripts need to know nothing
about the bar. Stop from a click with `capture-screenrecording --stop-recording`, which
fails instead of starting one when nothing is recording.

## Requirements

`tensaku` (AUR) is the annotation editor the notification opens; `SCREENSHOT_EDITOR`
overrides it. `gpu-screen-recorder` (extra) does the recording. Nothing here uses grimblast
any more, so `grimblast-git` can go on the next package sweep.
