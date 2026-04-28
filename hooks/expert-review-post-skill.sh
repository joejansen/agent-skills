#!/usr/bin/env bash
# expert-review-post-skill.sh — PostToolUse hook for Skill
# If expert-review-panel just completed (pending marker exists), record the
# current working tree hash so the Stop hook knows changes have been reviewed.

if [ -f .claude/expert-review-pending ]; then
  rm .claude/expert-review-pending

  # Pick an available hash command
  if command -v shasum >/dev/null 2>&1; then
    HASH_CMD="shasum"
  elif command -v sha256sum >/dev/null 2>&1; then
    HASH_CMD="sha256sum"
  else
    exit 0
  fi

  # Hash tracked changes + untracked file list (must match gate script)
  (git diff HEAD 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null) | "$HASH_CMD" | cut -d' ' -f1 > .claude/expert-review-hash
fi
