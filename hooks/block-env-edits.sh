#!/usr/bin/env bash
# block-env-edits.sh — PreToolUse hook for Edit|Write
# Blocks modifications to .env files (use .env.example instead).
#
# The target file's path arrives in the hook's stdin JSON as
# tool_input.file_path. Claude Code does NOT set a CLAUDE_FILE_PATH env var;
# a hook that reads one is a silent no-op.
#
# This hook is a guard, so it fails CLOSED: unparseable input blocks. Matching
# runs in isolated Python (-I, so a planted json.py in the cwd can't hijack it),
# case-insensitively (macOS filesystems are), on both the raw path and its
# symlink-resolved target.
if ! command -v python3 >/dev/null 2>&1; then
  echo 'BLOCKED: python3 is required to parse hook input for the .env guard' >&2
  exit 2
fi

python3 -I -c '
import json, os, sys

try:
    path = json.load(sys.stdin).get("tool_input", {}).get("file_path", "")
except Exception:
    print("BLOCKED: could not parse hook input for the .env guard", file=sys.stderr)
    sys.exit(2)
if not isinstance(path, str):
    print("BLOCKED: unexpected file_path in hook input for the .env guard", file=sys.stderr)
    sys.exit(2)
if not path:
    sys.exit(0)
if "\n" in path or "\r" in path:
    print("BLOCKED: file path contains a newline", file=sys.stderr)
    sys.exit(2)

def is_env(p):
    name = os.path.basename(p).lower()
    if name == ".env.example":
        return False
    return name == ".env" or name.startswith(".env.")

if is_env(path) or is_env(os.path.realpath(path)):
    print("BLOCKED: Do not modify .env files — use .env.example instead", file=sys.stderr)
    sys.exit(2)
sys.exit(0)
'
