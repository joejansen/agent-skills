#!/bin/bash

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$cwd")

# -e not -d: in a git worktree (e.g. every Conductor workspace) .git is a
# *file* pointing at the common dir, so -d silently hid the branch.
git_branch=""
if [ -e "$cwd/.git" ]; then
    git_branch=$(cd "$cwd" && git branch --show-current 2>/dev/null)
fi

context_size=$(echo "$input" | jq -r '.context_window.context_window_size')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

total_used=$((total_input + total_output))
remaining=$((context_size - total_used))

status="$model in $dir_name"

if [ -n "$git_branch" ]; then
    status="$status [$git_branch]"
fi

if [ -n "$used_pct" ]; then
    used_pct_rounded=$(printf "%.0f" "$used_pct")
    status="$status | Context: ${used_pct_rounded}%"
fi

if [ "$remaining" -ge 0 ] 2>/dev/null; then
    if [ "$remaining" -ge 1000 ]; then
        remaining_k=$((remaining / 1000))
        status="$status | ${remaining_k}k left"
    else
        status="$status | ${remaining} left"
    fi
fi

echo "$status"
