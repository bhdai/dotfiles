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

Anything that does not fit that model — root-owned files under `/etc` and `/opt`,
directories the tools themselves write to — is documented next to the files it
deploys. Every deploy command in those files is written to run from this repo root.

| Where | What |
|---|---|
| [`agentic/`](agentic/README.md) | Claude Code and Codex config, linked file by file into `~/.claude` and `~/.codex` |
| [`attention/`](attention/README.md) | Which tmux pane is waiting on you and what every agent is doing: the daemon, the agent hooks, and the user unit |
| [`config/hypr/`](config/hypr/README.md) | Session locking: one entry point, the fallback chain, and how to apply a change |
| [`system/keyd/`](system/keyd/README.md) | Keyboard remapping, `/etc/keyd` |
| [`system/pam.d/`](system/pam.d/README.md) | PAM services for the Quickshell lock screen, and the safe procedure for testing them |
| [`system/systemd/`](system/systemd/README.md) | Clearing fprintd state across suspend |
| [`system/tlp/`](system/tlp/README.md) | Battery charge thresholds |
| [`system/zapret/`](system/zapret/README.md) | SNI-filtering bypass |
| [`system/zmk/`](system/zmk/README.md) | Sofle keyboard firmware (submodule, built in its own CI), and how to flash it |

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
