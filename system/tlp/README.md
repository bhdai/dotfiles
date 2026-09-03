# tlp

Battery charge thresholds for the X1 Carbon Gen 11 (start 65%, stop 70%) via a
`/etc/tlp.d/` drop-in. `tlp.conf` overrides `tlp.d/` for the same key, so this only
works because every `*_CHARGE_THRESH_*` line in `tlp.conf` stays commented. Needs
the `tlp-pd` package (pulls in `tlp`); it's hardware-specific (`BAT0`, natacpi).
Deploy with:

```bash
sudo install -Dm644 system/tlp/10-battery-care.conf /etc/tlp.d/10-battery-care.conf &&
sudo tlp start
```

Verify with `sudo tlp-stat -b` (`stopThreshold = 70`). Charge to full before a day
away from power with `sudo tlp fullcharge BAT0`; unplugging, rebooting, or `tlp start`
restores the configured thresholds. Drift check: `diff system/tlp/10-battery-care.conf /etc/tlp.d/10-battery-care.conf`.

## Power profiles

`TLP_PROFILE_BAT=SAV` via a second drop-in, so unplugging drops to power-saver instead of
TLP's stock `BAL`. AC stays on `PRF`. The profile switcher in quickshell talks to `tlp-pd`
over `org.freedesktop.UPower.PowerProfiles`, so it reflects this too. Deploy with:

```bash
sudo install -Dm644 system/tlp/20-power-profiles.conf /etc/tlp.d/20-power-profiles.conf &&
sudo tlp start
```

Verify with `tlpctl list` on battery (`*` on `power-saver`).
