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
sudo pacman -S --needed pamtester            # the CLI gate; not installed by default
sha256sum /etc/pam.d/{system-auth,system-login,system-local-login,sudo,su,other} > /tmp/pam-before
pkill hypridle                               # nothing locks the screen mid-edit
journalctl -f &                              # PAM config errors only ever land here
```

There is no `polkit-1` service file here, so polkit resolves through `other` — that
is why `other` is in the snapshot and `polkit-1` is not.

Then open a **root shell on another VT** (`Ctrl+Alt+F2`, log in as root) and leave it
open for the whole session. Every check below runs as your normal user, against the
policy in isolation — never against your live session.

```bash
# password: correct passes, empty fails
pamtester quickshell-lock $USER authenticate

# lockout text after the deny=3 default is exceeded — the 4th attempt is the one
# that reports it, so run this four times with a wrong password
pamtester -v quickshell-lock $USER authenticate
faillock --reset                             # unprivileged for your own user; do this between rounds

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

Restart hypridle (`hyprctl dispatch exec hypridle`) and close the root VT when the
run is clean.
