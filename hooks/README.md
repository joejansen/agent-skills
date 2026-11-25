# Hooks

Shell scripts for Claude Code hooks. The harness runs only hooks registered in
a `settings.json` (`~/.claude/settings.json` for every project, or a project's
`.claude/settings.json`).

Hook input arrives as JSON on stdin (for Edit/Write, the path is
`tool_input.file_path`). Claude Code does not set a `CLAUDE_FILE_PATH`
environment variable; an inline hook that reads one silently does nothing.

## What's here

| Script | Event / matcher | Purpose |
| --- | --- | --- |
| `block-env-edits.sh` | `PreToolUse` `Edit\|Write` | Blocks edits to `.env` and `.env.*` (allows `.env.example`). Fails closed if it can't parse its input. Needs `python3`. |
| `ruff-format-file.sh` | `PostToolUse` `Edit\|Write` | Runs `ruff check --fix` and `ruff format` on an edited `.py` file inside the project. Prefers `.venv/bin/ruff`, else `ruff` on PATH. |
| `ruff-check-gate.sh` | `Stop` | Blocks stopping while `ruff check` / `ruff format --check` fail (`RUFF_TARGET`, default `.`). Skips under GitHub Actions; if ruff is missing it blocks once, then lets the agent stop and report lint as unverified. |
| `anchor-bash-cwd.sh` | `PreToolUse` `Bash` | Prefixes every Bash command with `cd <project root> &&` (or the session's `.claude/worktrees/<name>` worktree), so a `cd` in one call never leaks into the next. Needs `jq`. |
| `bash-failure-context.sh` | `PostToolUseFailure` `Bash` | After a failed Bash call, tells the agent commands are anchored to the project root, so it fixes relative-path mistakes itself. Pair with `anchor-bash-cwd.sh`. Needs `jq`. |

The ruff hooks are a Python example; copy the pattern for `eslint`, `mypy`,
`cargo clippy`, and so on. Running a project's `.venv/bin/ruff` runs code the
project controls, so wire them only into repositories you trust.

## Setup

Make the scripts executable (`chmod +x hooks/*.sh`) and reference them by
absolute path, or copy them into a project's `.claude/hooks/`. Example for
user scope (replace `<agent-skills>` with your clone's absolute path):

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "<agent-skills>/hooks/anchor-bash-cwd.sh", "timeout": 10 } ] },
      { "matcher": "Edit|Write", "hooks": [ { "type": "command", "command": "bash <agent-skills>/hooks/block-env-edits.sh" } ] }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [ { "type": "command", "command": "bash <agent-skills>/hooks/ruff-format-file.sh" } ] }
    ],
    "PostToolUseFailure": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "<agent-skills>/hooks/bash-failure-context.sh", "timeout": 10 } ] }
    ],
    "Stop": [
      { "hooks": [ { "type": "command", "command": "RUFF_TARGET=. bash <agent-skills>/hooks/ruff-check-gate.sh" } ] }
    ]
  }
}
```

In a project's `.claude/settings.json`, use
`bash "$CLAUDE_PROJECT_DIR"/.claude/hooks/<script>.sh` so the path works from
any checkout or worktree.

## Caveats

- Every script exits 0 (skips) outside a git repository or when there is
  nothing for it to act on, so scratch sessions aren't blocked.
- `anchor-bash-cwd.sh` rewrites every Bash command. Some harnesses also run
  their own cwd hooks; don't stack two rewriters.
