# PAM policies for the quickshell lock screen

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

## Safe test procedure

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
