#!/usr/bin/env bash
# ruff-check-gate.sh — Stop hook (Python / ruff example)
#
# Blocks stopping if `ruff check` or `ruff format --check` would fail.
# Useful as a CI mirror so the agent can't declare "done" while lint is broken.
#
# Configure the lint target with the RUFF_TARGET env var (default: ".").
# Example: RUFF_TARGET=src/ in your settings.json hook command.
#
# This is intended as a *pattern* — copy it and adapt for other tools:
#   - pytest:  run tests, fail closed
#   - eslint:  npx eslint "$ESLINT_TARGET"
#   - mypy:    mypy "$MYPY_TARGET"
#   - cargo:   cargo check / cargo clippy

# Skip if not inside a git repository (don't block scratch/agentic edits)
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

# cd to repo root so the lint runs the same way CI would
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  exit 0
fi
cd "$REPO_ROOT"

# Block if ruff is not installed — install with: uv pip install ruff
if ! command -v ruff >/dev/null 2>&1; then
  echo "BLOCKED: ruff not found in PATH. Install with: uv pip install ruff" >&2
  exit 2
fi

TARGET="${RUFF_TARGET:-.}"
SUCCESS=true

if ! ruff check "$TARGET" 2>&1; then
  SUCCESS=false
fi

if ! ruff format --check "$TARGET" 2>&1; then
  SUCCESS=false
fi

if [ "$SUCCESS" = false ]; then
  echo "" >&2
  echo "BLOCKED: Fix ruff lint/format issues before finishing." >&2
  exit 2
fi
