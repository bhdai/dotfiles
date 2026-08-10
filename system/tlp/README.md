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

Verify with `sudo tlp-stat -b` (`stopThreshold = 70`). Raise the stop threshold for a
day away from power with `sudo tlp setcharge 0 100 BAT0`; it reverts on the next
`tlp start` or reboot. Drift check: `diff system/tlp/10-battery-care.conf /etc/tlp.d/10-battery-care.conf`.
