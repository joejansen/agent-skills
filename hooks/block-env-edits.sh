#!/usr/bin/env bash
# block-env-edits.sh — PreToolUse hook for Edit|Write
# Blocks modifications to .env files (use .env.example instead).
#
# The target file's path arrives in the hook's stdin JSON as
# tool_input.file_path — Claude Code does NOT set a CLAUDE_FILE_PATH env var
# (the previous inline version of this hook read that var and was a silent
# no-op: it never blocked anything).

# This hook is a guard, so it fails CLOSED: if the input can't be parsed we
# block rather than silently allow .env edits. An empty file_path in
# well-formed input is fine (the Edit|Write matcher always supplies one).
if ! command -v python3 >/dev/null 2>&1; then
  echo 'BLOCKED: python3 is required to parse hook input for the .env guard' >&2
  exit 2
fi

FILE=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input", {}).get("file_path", ""))' 2>/dev/null)
if [ $? -ne 0 ]; then
  echo 'BLOCKED: could not parse hook input for the .env guard' >&2
  exit 2
fi

if [ -z "$FILE" ]; then
  exit 0
fi

if echo "$FILE" | grep -q '\.env\.example$'; then
  exit 0
fi

if echo "$FILE" | grep -qE '(^|/)\.env(\..+)?$'; then
  echo 'BLOCKED: Do not modify .env files — use .env.example instead' >&2
  exit 2
fi
exit 0
