# dotfiles

Everything in `config/` symlinks to `~/.config/<same name>`, managed by the `dot`
function in `config/fish/functions/dot.fish`. `dot status` reports what is linked,
what drifted, and whether the `system/` files below still match what is deployed.

On a new machine, link fish by hand first — `dot` ships inside it, so it cannot
link itself:

```bash
ln -s ~/ghq/github.com/bhdai/dotfiles/config/fish ~/.config/fish
dot link all
```

## agentic

Claude Code and Codex read from `~/.claude` and `~/.codex`, not `~/.config`, and
they fill those directories with runtime state (sessions, caches, credentials).
So `agentic/` is linked file by file rather than as a whole directory, and `dot`
deliberately ignores it:

```bash
ln -sfn ~/ghq/github.com/bhdai/dotfiles/agentic/AGENTS.md ~/.claude/CLAUDE.md
ln -sfn ~/ghq/github.com/bhdai/dotfiles/agentic/AGENTS.md ~/.codex/AGENTS.md
for f in settings.json statusline.sh statusline-git.sh
    ln -sfn ~/ghq/github.com/bhdai/dotfiles/agentic/claude/$f ~/.claude/$f
end
ln -sfn ~/ghq/github.com/bhdai/dotfiles/agentic/claude/skills/deep-research ~/.claude/skills/deep-research
```

Use `ln -sfn`, not `ln -s`: the target directories already exist, and plain `ln -s`
silently creates the link *inside* them instead of failing.

## KDE default terminal

Dolphin launches `Terminal=true` desktop entries (Neovim, etc.) through KDE's
`KTerminalLauncherJob`, which hardcodes konsole and errors with `Terminal konsole
not found` when konsole is absent. The installed KIO (Plasma 6.7) predates
`xdg-terminal-exec` support, so `xdg-terminals.list` and `$TERMINAL` are ignored —
the only knob it reads is `TerminalApplication` in `kdeglobals`. KDE rewrites that
file on every settings change, so it isn't symlinked; add these two keys to the
`[General]` group in `~/.config/kdeglobals` by hand (KDE preserves keys it doesn't
manage):

```ini
[General]
TerminalApplication=ghostty
TerminalService=com.mitchellh.ghostty.desktop
```

## keyd

`keyd` config lives at `/etc/keyd/default.conf` (system-level, root-owned), so it
can't be symlinked into `~/.config` like the rest. Deploy it with:

```bash
sudo install -Dm644 system/keyd/default.conf /etc/keyd/default.conf && sudo keyd reload
```

`install -D` creates missing parent dirs and `-m644` sets the mode in one atomic step.

## zapret

Bypasses the ISP's SNI filtering for the domains listed in
`system/zapret/zapret-hosts-user.txt`. Needs the `zapret-git` AUR package, which
owns `/opt/zapret`. Deploy both files with:

```bash
sudo install -Dm644 system/zapret/config /opt/zapret/config &&
sudo install -Dm644 system/zapret/zapret-hosts-user.txt /opt/zapret/ipset/zapret-hosts-user.txt &&
sudo systemctl restart zapret
```

The DPI matches the TLS ClientHello signature (`16 03 01`) only at the start of a
TCP segment, so `--dpi-desync=multisplit --dpi-desync-split-pos=1` splits the
record header after byte 1 and its parser never engages — it never reads the SNI.
`MODE_FILTER=hostlist` keeps this scoped to listed domains; all other traffic is
unmodified. No tunnel, no proxy, real exit IP.

Adding a domain is an edit to the hostlist plus `sudo systemctl restart zapret`.
After a zapret upgrade, `diff system/zapret/config /opt/zapret/config` shows
whether upstream changed the defaults underneath our five `[dotfiles]` edits.

## tlp

Battery charge thresholds for the X1 Carbon Gen 11 (start 65%, stop 70%) via a
`/etc/tlp.d/` drop-in. `tlp.conf` overrides `tlp.d/` for the same key, so this only
works because every `*_CHARGE_THRESH_*` line in `tlp.conf` stays commented. Needs
the `tlp-pd` package (pulls in `tlp`); it's hardware-specific (`BAT0`, natacpi).
Deploy with:

```bash
sudo install -Dm644 system/tlp/10-battery-care.conf /etc/tlp.d/10-battery-care.conf &&
sudo tlp start
```

Verify with `sudo tlp-stat -b` (`stopThreshold = 70`). Raise the stop threshold for a
day away from power with `sudo tlp setcharge 0 100 BAT0`; it reverts on the next
`tlp start` or reboot. Drift check: `diff system/tlp/10-battery-care.conf /etc/tlp.d/10-battery-care.conf`.

## PAM policies for the quickshell lock screen

The Quickshell lock screen authenticates through two concurrent `PamContext`
objects — password and fingerprint — and each one needs its own PAM service. Both
are **new service names**, so they are scoped correctly by construction: sudo, su,
sshd, polkit and login never resolve them. Nothing under `/etc/pam.d/` that already
exists is edited.

`quickshell-lock` includes the **system auth** stack rather than `login`. Including
`login` drags in `pam_nologin`, which refuses to unlock your own running session
whenever `/etc/nologin` exists (a file `shutdown(8)` creates), and `pam_shells`,
which makes unlocking depend on your login shell staying listed in `/etc/shells`.
Going straight to `system-auth` keeps the failure counter, `pam_unix` and `pam_env`
and drops both hazards. (`/etc/pam.d/hyprlock` includes `login`; it is a verbatim
copy of swaylock's file, inherited rather than chosen. Leave it alone — hyprlock
stays as the fallback locker.)

`quickshell-fprint` carries **no failure counter**. A fingerprint-only stack has no
failure line, so failed fingers never increment the tally either way — a preauth
line buys no rate limiting and only couples the two factors. That coupling costs the
escape hatch: mistype your password three times, get locked out for ten minutes, and
your finger stops working too, leaving only a TTY.

`pam_fprintd.so` must appear **only** in this one file. Fingerprint auth for
sudo/su/polkit "allows background processes to obtain permissions without prompting
the user for a fingerprint" (ArchWiki `fprint`), and CVE-2024-37408 records that
fprintd lacks a security attention mechanism. `/etc/pam.d/sudo` includes `system-auth`
on this machine, so a fingerprint line there would leak into sudo immediately.

Deploy both files with:

```bash
sudo install -Dm644 system/pam.d/quickshell-lock /etc/pam.d/quickshell-lock &&
sudo install -Dm644 system/pam.d/quickshell-fprint /etc/pam.d/quickshell-fprint
```

No reload — PAM reads the service file on every `pam_start`. The lock screen is
broken until this line has been run on a machine; a missing service file fails
closed and the shell reports it rather than hanging. Drift check:
`diff -r system/pam.d/ /etc/pam.d/ | grep quickshell`.

### Safe test procedure

Do the setup **before** the first edit, not after something breaks. PAM logs config
errors to syslog and shows nothing in the UI, so watch the journal throughout.

```bash
yay -S --needed pamtester                    # the CLI gate; AUR, not in the official repos
sha256sum /etc/pam.d/{system-auth,system-login,system-local-login,sudo,su,other} > /tmp/pam-before
pkill hypridle                               # nothing locks the screen mid-edit
journalctl -f &                              # PAM config errors only ever land here
```

There is no `polkit-1` service file here, so polkit resolves through `other` — that
is why `other` is in the snapshot and `polkit-1` is not.

If you skipped the snapshot, `pacman -Qkk pambase sudo util-linux` checks the same
thing after the fact and more strictly, against the package database rather than
against your own earlier copy.

Then open a **root shell on another VT** — `Ctrl+Alt+F3`, log in as root — and leave
it open for the whole session. **F2 is sddm on this machine, not a free TTY.** Every
check below runs as your normal user, against the policy in isolation — never
against your live session.

```bash
# password: correct passes, empty fails
pamtester quickshell-lock $USER authenticate

# lockout text after the deny=3 default is exceeded — the 4th attempt is the one
# that reports it, so run this four times with a wrong password
pamtester -v quickshell-lock $USER authenticate
faillock --user $USER --reset                # between rounds; bare `faillock --reset` also
                                             # tries root's tally and errors on it

# fingerprint: enrolled finger passes, any other finger fails
pamtester quickshell-fprint $USER authenticate

# a service name that does not exist must fail closed
pamtester quickshell-nope $USER authenticate
```

Finally prove nothing shared moved, and that the fingerprint module is confined to
the one new file:

```bash
sha256sum -c /tmp/pam-before                 # every line must say OK
grep -rl pam_fprintd /etc/pam.d/             # must print quickshell-fprint and nothing else
```

Restart hypridle with `setsid hypridle >/dev/null 2>&1 &`, and close the root VT when
the run is clean. `hyprctl dispatch exec hypridle` does **not** work here — the Lua
config parses the dispatch argument as Lua and rejects the bare word.

What a green run looks like, observed 2026-07-28:

| Check | Expected |
|---|---|
| Correct password | `authentication successful` |
| Empty password | `Authentication token manipulation error`, exit 1 |
| 4× wrong password | `Authentication failure` each time; the 4th **also** prints `The account is locked due to 3 failed logins. (10 minutes left to unlock)` |
| Enrolled finger | passes; any other finger fails |
| `quickshell-nope` | `Authentication failure` with **no prompt at all** — unknown services fall through to `/etc/pam.d/other`, which is `pam_deny` + `pam_warn` |

Two log lines that look like faults and are not: `pam_faillock: Error sending audit
message: Operation not permitted` is pamtester running unprivileged and unable to
write audit records — the tally and the lockout both still work, and Quickshell will
produce the same line for the same reason. And `pam_unix` does not log successful
authentications at the default level, so a clean run leaves no positive trace in the
journal; absence of a success line is not evidence of failure.

## Session locking

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

**hyprlock stays installed**, with `config/hypr/hyprlock.conf` and `/etc/pam.d/hyprlock`
left alone. It is the last link in `lock_cmd` for the one case where a fallback is real:
the shell already dead when the lock is *requested*, so nothing holds the lock yet and no
compositor flag is involved. Once Quickshell holds the lock, no second client can take it
over — see `config/quickshell/docs/research/lock-client-death.md` for recovery from a
session left locked with no client.

Hyprland's session-lock restore (`misc:allow_session_lock_restore`) stays **off**. It
would let a new lock client adopt an existing lock, which is a way back into a locked
session rather than a way out of a dead one.

### One-time steps on a new machine

The PAM install line above, plus the avatar the lock screen reads:

```bash
ln -sf ~/Pictures/profile/bird_profile.png ~/.face
```

`~/.face` is the convention SDDM, GDM and LightDM already read, so one file drives the
lock screen and any future display manager instead of letting them drift. Missing or
unreadable, the lock screen draws a themed `person` symbol rather than a broken image.

### Applying a change

`hypridle.conf` and `binds.lua` are read at startup, not watched:

```bash
pkill hypridle; setsid hypridle >/dev/null 2>&1 &   # autostarted by Hyprland, not a user unit
hyprctl reload                                      # picks up binds.lua
```

`hyprctl dispatch exec hypridle` does **not** work here, for the reason given in the safe
test procedure above.

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
