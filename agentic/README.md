# agentic

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
