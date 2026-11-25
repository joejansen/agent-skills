#!/usr/bin/env bash
# PostToolUseFailure hook on Bash: when a Bash call exits non-zero, inject
# the project root into Claude's context so it can self-correct path errors.
set -euo pipefail

dir="${CLAUDE_PROJECT_DIR:-unknown}"
jq -nc --arg dir "$dir" '
  {
    hookSpecificOutput: {
      hookEventName: "PostToolUseFailure",
      additionalContext: ("Bash commands are auto-prefixed with `cd " + $dir + " && ` so cwd is reset to the workspace root at the start of every call. If this command failed with \"No such file or directory\", verify the path exists relative to " + $dir + " — relative paths from a previous `cd` no longer carry over between calls.")
    }
  }
'
