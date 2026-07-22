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
