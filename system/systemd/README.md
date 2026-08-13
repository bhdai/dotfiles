# fprintd across suspend

The Synaptics Prometheus (`06cb:00fc`) disconnects and re-enumerates under a new USB
device number on resume — not always, and distinct from the plain `reset` that is
harmless. When it does, a resident fprintd can be left with **two** device objects for
the one sensor: the live one, and a corpse bound to the dead handle whose `Release`
failed with `USB error ... Input/Output Error`, leaving a claim held with no client
alive to own it.

`pam_fprintd` calls `GetDevices` and takes element `[0]` — it never calls
`GetDefaultDevice`, and the list order is not a stable function of object age. So
whether fingerprint unlock keeps working is decided by which of the two happens to land
at index 0. When it is the corpse, every `Claim` is refused (`Device was already
claimed`), the lock screen spends its retry budget and the chip disappears.

Nothing in the shell can route around this: the device choice belongs to `pam_fprintd`.
The first half of the fix is to make sure no fprintd state ever crosses a sleep, so the
clean-recovery case becomes the only case.

That is necessary and not sufficient. On its own it moves the failure rather than
removing it. With no resident daemon, the lock screen becomes the thing that starts one:
it re-arms the reader the instant `user.slice` thaws, and that D-Bus-activates fprintd
about a second before the Prometheus has finished re-enumerating. fprintd enumerates
readers once, at startup, and holds that answer until it exits — so the instance that
answers for the whole lock session has an empty device list and refuses every scan.
Observed 2026-08-11 20:14, one second after the lid opened:

    fprintd[59235]: libusb couldn't open USB device /dev/bus/usb/003/000, errno=2
    fprintd[59235]: Ignoring device due to initialization error: ... No such device
    fprintd.service: Deactivated successfully          # 30s idle exit, t+30.5s

The symptom is identical to the corpse above — the chip disappears for the rest of the
lock — but the cause is the opposite: no device rather than the wrong one. The lock
screen's retry budget is spent inside that single instance's life, so every retry reaches
the same empty daemon, and each retry restarts its idle timer. Retrying more often is
therefore strictly worse, which is why the budget alone never recovers.

`fprintd-drop-empty` closes it: a systemd-sleep hook that, for twenty seconds after a
resume, drops any fprintd it finds with no reader. It polls rather than checking once,
because when the reader becomes usable is not knowable in advance — measured across five
resumes here it ranged from 200ms *before* the resume was announced to 1.2s after,
tracking whether the sleep ran long enough for the port to lose power. A single
well-chosen moment is right for one of those resumes and wrong for the next. A daemon
that can see the reader is always left alone, so a scan in flight is never killed
underneath the user.

The shell holds the other half — a retry wait long enough to outlive a daemon — in
`quickshell_config`'s `services/LockLogic.js`. Either half recovers alone. Together the
chip comes back about three seconds after a resume rather than about a minute, and the
pair is tolerant of a change in fprintd's idle timeout.

Roughly two seconds of that three is the floor: the reader is not usable for ~1.5s, and a
cold fprintd needs ~0.3s more to start and enumerate. Tightening the shell's early retries
to close the remaining gap was measured and rejected — the hook's poll interval and the
retry schedule are independent timers, and interleaving them more finely made the result
worse as often as better.

```bash
sudo install -Dm644 system/systemd/fprintd-reset-on-resume.service \
    /etc/systemd/system/fprintd-reset-on-resume.service &&
sudo install -Dm644 system/systemd/fprintd-stop-timeout.conf \
    /etc/systemd/system/fprintd.service.d/timeout.conf &&
sudo install -Dm755 system/systemd/system-sleep/fprintd-drop-empty \
    /usr/lib/systemd/system-sleep/fprintd-drop-empty &&
sudo systemctl daemon-reload &&
sudo systemctl enable fprintd-reset-on-resume.service
```

The hook needs no `daemon-reload` or `enable` of its own — `systemd-sleep` rescans that
directory on every transition.

The diagnostic is the object count, and a restart destroys the evidence — check before
clearing anything:

```bash
FP=net.reactivated.Fprint
busctl --system call $FP /net/reactivated/Fprint/Manager $FP.Manager GetDevices
```

More than one object for one sensor means the wedge. `sudo systemctl restart fprintd`
clears it by hand. Full forensics, including the hypotheses that were tested and
falsified, are in `~/ghq/github.com/bhdai/research/diagnostics/`.
