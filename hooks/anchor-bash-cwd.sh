#!/usr/bin/env bash
# PreToolUse hook on Bash: prepend `cd <anchor> &&` so every Bash call resets to
# the workspace root. Defeats cwd drift between calls. The anchor is
# $CLAUDE_PROJECT_DIR, or the session's worktree when the session has entered one
# under .claude/worktrees/ (EnterWorktree leaves CLAUDE_PROJECT_DIR on the primary
# checkout, and anchoring there makes the worktree-isolation guard refuse git).
set -euo pipefail

if [[ -z "${CLAUDE_PROJECT_DIR:-}" ]]; then
  exit 0
fi

jq -c --arg dir "$CLAUDE_PROJECT_DIR" '
  ((.cwd // "") as $cwd
    | ($cwd | ltrimstr($dir + "/.claude/worktrees/")) as $rest
    | if $rest != $cwd and ($rest | length) > 0
      then $dir + "/.claude/worktrees/" + ($rest | split("/")[0])
      else $dir end) as $anchor
  | {
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        updatedInput: (.tool_input | .command = ("cd " + ($anchor | @sh) + " && " + .command))
      }
    }
'
