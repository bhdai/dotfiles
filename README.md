# dotfiles

## keyd

`keyd` config lives at `/etc/keyd/default.conf` (system-level, root-owned), so it
can't be symlinked into `~/.config` like the rest. Deploy it with:

```bash
sudo install -Dm644 system/keyd/default.conf /etc/keyd/default.conf && sudo keyd reload
```

`install -D` creates missing parent dirs and `-m644` sets the mode in one atomic step.
