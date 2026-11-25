#!/usr/bin/env bash
# ruff-format-file.sh — PostToolUse hook for Edit|Write (Python / ruff example)
#
# Auto-fixes and formats an edited .py file inside the project.
#
# The edited file's path arrives in the hook's stdin JSON as
# tool_input.file_path. Claude Code does NOT set a CLAUDE_FILE_PATH env var;
# a hook that reads one is a silent no-op.
#
# Uses the project's own .venv/bin/ruff when present (so the version matches
# the lockfile CI uses), else ruff on PATH. Running the project's ruff runs
# project-controlled code: wire this only into repositories you trust.

unset GIT_DIR GIT_WORK_TREE GIT_COMMON_DIR
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
if [ -z "$ROOT" ]; then
  exit 0
fi
ROOT=$(cd "$ROOT" && pwd -P)

FILE=$(python3 -c 'import json,os,sys; p=json.load(sys.stdin).get("tool_input", {}).get("file_path", ""); print(os.path.realpath(p) if p else "")' 2>/dev/null)
if [ -z "$FILE" ] || [ "${FILE%.py}" = "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi
# Only format files inside this project.
case "$FILE" in
  "$ROOT"/*) ;;
  *) exit 0 ;;
esac

if [ -x "$ROOT/.venv/bin/ruff" ]; then
  RUFF="$ROOT/.venv/bin/ruff"
elif command -v ruff >/dev/null 2>&1; then
  RUFF=ruff
else
  # The ruff-check-gate Stop hook reports a missing ruff loudly.
  exit 0
fi

cd "$ROOT"
"$RUFF" check --fix --quiet -- "$FILE"
"$RUFF" format --quiet -- "$FILE"
exit 0
