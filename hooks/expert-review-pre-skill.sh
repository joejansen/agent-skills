#!/usr/bin/env bash
# expert-review-pre-skill.sh — PreToolUse hook for Skill
# Detects when /expert-review-panel is about to run and sets a pending marker
# so the PostToolUse hook knows to record the diff hash after completion.

INPUT=$(cat)
if echo "$INPUT" | grep -q 'expert-review-panel'; then
  touch .claude/expert-review-pending
fi
exit 0
