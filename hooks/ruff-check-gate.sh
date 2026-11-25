#!/usr/bin/env bash
# ruff-check-gate.sh — Stop hook (Python / ruff example)
#
# Blocks stopping if `ruff check` or `ruff format --check` would fail, so the
# agent can't declare "done" while lint is broken.
#
# Configure the lint target with RUFF_TARGET (default: "."), e.g.
#   RUFF_TARGET=src/ bash .claude/hooks/ruff-check-gate.sh
#
# Uses the project's .venv/bin/ruff when present (matching the lockfile CI
# uses), else ruff on PATH. Running the project's ruff runs project-controlled
# code: wire this only into repositories you trust.
#
# This is a pattern — copy it for pytest, eslint, mypy, cargo clippy, etc. The
# load-bearing parts: lint the project root, skip in CI runners, exit 2 to
# block, and block at most once per stop when the tool can't run at all.

unset GIT_DIR GIT_WORK_TREE GIT_COMMON_DIR
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
if [ -z "$ROOT" ] || ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi
cd "$ROOT" || exit 0

# An agent running inside GitHub Actions has no project environment; CI owns
# lint there, and blocking would only loop every run.
if [ -n "${GITHUB_ACTIONS:-}" ]; then
  exit 0
fi

INPUT=$(cat)

if [ -x "$ROOT/.venv/bin/ruff" ]; then
  RUFF="$ROOT/.venv/bin/ruff"
elif command -v ruff >/dev/null 2>&1; then
  RUFF=ruff
else
  # A session that can't install ruff can never satisfy this gate, so block
  # once: when this stop already follows a Stop-hook block (stop_hook_active),
  # let it end with lint unverified rather than loop forever.
  if printf '%s' "$INPUT" | python3 -I -c 'import json, sys; sys.exit(0 if json.load(sys.stdin).get("stop_hook_active") is True else 1)' 2>/dev/null; then
    exit 0
  fi
  echo "BLOCKED: ruff not found (.venv/bin/ruff or PATH). Install it, or say plainly in your final report that the Python changes are unlinted." >&2
  exit 2
fi

TARGET="${RUFF_TARGET:-.}"
SUCCESS=true
"$RUFF" check "$TARGET" 2>&1 || SUCCESS=false
"$RUFF" format --check "$TARGET" 2>&1 || SUCCESS=false

if [ "$SUCCESS" = false ]; then
  echo "" >&2
  echo "BLOCKED: Fix ruff lint/format issues before finishing." >&2
  exit 2
fi
exit 0
