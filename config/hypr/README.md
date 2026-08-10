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
