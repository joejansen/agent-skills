#!/usr/bin/env bash
# expert-review-gate.sh — Stop hook
# Blocks stopping if files have changed since the last /expert-review-panel run.
# State is tracked via .claude/expert-review-hash (hash of working tree state at review time).

# Skip if not in a git repo or HEAD is unavailable
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  exit 0
fi

# No changes (tracked or untracked) → nothing to review
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  exit 0
fi

# Pick an available hash command
if command -v shasum >/dev/null 2>&1; then
  HASH_CMD="shasum"
elif command -v sha256sum >/dev/null 2>&1; then
  HASH_CMD="sha256sum"
else
  echo "Error: neither 'shasum' nor 'sha256sum' is available." >&2
  exit 1
fi

# Hash tracked changes + untracked file list
CURRENT_HASH=$( (git diff HEAD 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null) | "$HASH_CMD" | cut -d' ' -f1)

# Changes match what was last reviewed → OK
if [ -f .claude/expert-review-hash ]; then
  REVIEWED_HASH=$(cat .claude/expert-review-hash)
  if [ "$CURRENT_HASH" = "$REVIEWED_HASH" ]; then
    exit 0
  fi
fi

echo "Files have changed since the last expert-review-panel run. Please run /expert-review-panel before finishing." >&2
exit 2
