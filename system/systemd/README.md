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
The fix is to make sure no fprintd state ever crosses a sleep, so the clean-recovery
case becomes the only case:

```bash
sudo install -Dm644 system/systemd/fprintd-reset-on-resume.service \
    /etc/systemd/system/fprintd-reset-on-resume.service &&
sudo install -Dm644 system/systemd/fprintd-stop-timeout.conf \
    /etc/systemd/system/fprintd.service.d/timeout.conf &&
sudo systemctl daemon-reload &&
sudo systemctl enable fprintd-reset-on-resume.service
```

The diagnostic is the object count, and a restart destroys the evidence — check before
clearing anything:

```bash
FP=net.reactivated.Fprint
busctl --system call $FP /net/reactivated/Fprint/Manager $FP.Manager GetDevices
```

More than one object for one sensor means the wedge. `sudo systemctl restart fprintd`
clears it by hand. Full forensics, including the hypotheses that were tested and
falsified, are in `~/ghq/github.com/bhdai/research/diagnostics/`.
