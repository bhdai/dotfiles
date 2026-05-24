#!/bin/bash
input=$(cat)

git_info=$(echo "$input" | bash ~/.claude/statusline-git.sh)

token_display=$(echo "$input" | node -e "
const d = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
const cw = d.context_window || {};
const usage = cw.current_usage || {};
const used = (usage.input_tokens || 0) + (usage.output_tokens || 0)
           + (usage.cache_creation_input_tokens || 0) + (usage.cache_read_input_tokens || 0);
const pct = cw.used_percentage || 0;
if (used === 0 && pct === 0) process.exit(0);
const k = used >= 1000 ? (used / 1000).toFixed(1) + 'k' : String(used);
const pctStr = pct.toFixed(1);
const color = pct < 50 ? '\x1b[32m' : pct < 80 ? '\x1b[33m' : '\x1b[31m';
process.stdout.write(color + k + ' (' + pctStr + '%)\x1b[0m');
")

if [ -n "$token_display" ]; then
  printf '%s | %s' "$git_info" "$token_display"
else
  printf '%s' "$git_info"
fi
