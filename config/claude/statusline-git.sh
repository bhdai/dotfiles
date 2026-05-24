#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | sed -n 's/.*"current_dir":"\([^"]*\)".*/\1/p')

BRANCH_ICON=$''
MODIFIED_ICON=$''
STAGED_ICON=$''

if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  repo_root=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
  repo_name=$(basename "$repo_root")
  rel_path=$(realpath --relative-to="$repo_root" "$cwd" 2>/dev/null)
  [ "$rel_path" = "." ] && display_name="$repo_name" || display_name="$repo_name/$rel_path"

  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

  metrics=$(git -C "$cwd" --no-optional-locks diff --shortstat 2>/dev/null)
  added=$(echo "$metrics" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
  deleted=$(echo "$metrics" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')

  modified=$(git -C "$cwd" --no-optional-locks diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  staged=$(git -C "$cwd" --no-optional-locks diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

  printf '\033[01m%s\033[00m on \033[01;32m%s %s\033[00m' "$display_name" "$BRANCH_ICON" "$branch"
  [ -n "$added" ] && [ "$added" -gt 0 ] && printf ' \033[32m+%s\033[00m' "$added"
  [ -n "$deleted" ] && [ "$deleted" -gt 0 ] && printf ' \033[31m-%s\033[00m' "$deleted"
  [ "$modified" -gt 0 ] && printf ' \033[34m%s %s\033[00m' "$MODIFIED_ICON" "$modified"
  [ "$staged" -gt 0 ] && printf ' \033[32m%s %s\033[00m' "$STAGED_ICON" "$staged"
else
  printf '\033[01m%s\033[00m' "$(basename "$cwd")"
fi
