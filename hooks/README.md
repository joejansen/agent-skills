# Hooks

These are shell scripts you wire into your agent's `settings.json`. They
aren't loaded automatically — the harness only runs hooks you've registered.

## What's here

| Script | Type | Purpose |
| --- | --- | --- |
| `expert-review-gate.sh` | `Stop` | Block stopping if files have changed since the last `/expert-review-panel` run. |
| `expert-review-pre-skill.sh` | `PreToolUse` (Skill) | Detect when `/expert-review-panel` is about to run; set a pending marker. |
| `expert-review-post-skill.sh` | `PostToolUse` (Skill) | After `/expert-review-panel` finishes, record the working-tree hash so `Stop` knows the change is reviewed. |
| `ruff-check-gate.sh` | `Stop` | Block stopping if `ruff check` or `ruff format --check` would fail. Configurable via `RUFF_TARGET` env var. |

The three `expert-review-*` scripts are a coordinated set — install all three
or none of them. Together they enforce: "you must run the expert review panel
on the current change before the agent is allowed to stop."

## Setup

1. Make the scripts executable:
   ```bash
   chmod +x hooks/*.sh
   ```

2. Either symlink the `hooks/` directory into each project that wants them:
   ```bash
   ln -s /absolute/path/to/agent-skills/hooks /your/project/.claude/hooks
   ```
   or copy the individual scripts into the project's `.claude/hooks/`.

3. Add hook entries to the project's `.claude/settings.json` (or your global
   `~/.claude/settings.json`). Example wiring all four:

   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Skill",
           "hooks": [
             {
               "type": "command",
               "command": "bash .claude/hooks/expert-review-pre-skill.sh"
             }
           ]
         }
       ],
       "PostToolUse": [
         {
           "matcher": "Skill",
           "hooks": [
             {
               "type": "command",
               "command": "bash .claude/hooks/expert-review-post-skill.sh"
             }
           ]
         }
       ],
       "Stop": [
         {
           "hooks": [
             { "type": "command", "command": "bash .claude/hooks/expert-review-gate.sh" }
           ]
         },
         {
           "hooks": [
             { "type": "command", "command": "RUFF_TARGET=. bash .claude/hooks/ruff-check-gate.sh" }
           ]
         }
       ]
     }
   }
   ```

## Inline hooks (no script needed)

A couple of patterns are short enough to keep inline in `settings.json`
rather than as standalone scripts. Two I use often:

### Auto-format Python on Edit/Write

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "FILE=\"$CLAUDE_FILE_PATH\"; if [ -n \"$FILE\" ] && echo \"$FILE\" | grep -q '\\.py$'; then ruff check --fix --quiet \"$FILE\"; ruff format --quiet \"$FILE\"; fi"
          }
        ]
      }
    ]
  }
}
```

### Block edits to `.env` files (allow `.env.example`)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "FILE=\"$CLAUDE_FILE_PATH\"; if [ -z \"$FILE\" ]; then exit 0; fi; if echo \"$FILE\" | grep -q '\\.env\\.example$'; then exit 0; fi; if echo \"$FILE\" | grep -qE '(^|/)\\.env(\\..+)?$'; then echo 'BLOCKED: Do not modify .env files — use .env.example instead' >&2; exit 2; fi"
          }
        ]
      }
    ]
  }
}
```

## Caveats

- All hooks assume a git repo. They `exit 0` (skip silently) when run outside
  one so they don't block `/init` or scratch sessions.
- `ruff-check-gate.sh` blocks (exit 2) if `ruff` isn't installed. That's a
  feature: if you wired this hook, it's because you want lint enforcement.
  Remove the hook for projects that don't use ruff.
- `expert-review-*` scripts write small marker files (`.claude/expert-review-pending`,
  `.claude/expert-review-hash`). Add these to your `.gitignore`.
