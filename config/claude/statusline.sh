#!/bin/bash
input=$(cat)

git_info=$(echo "$input" | bash ~/.claude/statusline-git.sh)

model_display=$(echo "$input" | node -e "
const d = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
const m = d.model || {};
const name = m.display_name || m.id || '';
if (!name) process.exit(0);
const short = name.replace(/^Claude\s+/i, '');
const fast = d.fast_mode || m.fast || m.fast_mode || d.fast
          || (m.id && /fast/i.test(m.id)) || (m.display_name && /fast/i.test(m.display_name));
const suffix = fast ? ' ⚡' : '';
// Use the default foreground colour (no SGR colour) so the model name
// reads as clearly as the plain 'on' separator in statusline-git.sh,
// instead of the dim bright-black (\x1b[90m) it used before.
process.stdout.write(short + suffix);
")

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

parts=()
[ -n "$model_display" ] && parts+=("$model_display")
[ -n "$git_info" ] && parts+=("$git_info")
[ -n "$token_display" ] && parts+=("$token_display")

printf '%s' "${parts[0]}"
for ((i=1; i<${#parts[@]}; i++)); do
  printf ' | %s' "${parts[$i]}"
done
