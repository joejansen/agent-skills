# agent-skills

A small, opinionated collection of skills, slash commands, and hooks for
agentic coding tools — Claude Code, Codex, and the Blocks app. Drop these
into your tool of choice to get a higher-quality default workflow for
shipping, reviewing, and finishing pull requests.

The skills here follow the [Agent Skills specification](https://agentskills.io/specification):
each skill is a directory containing a `SKILL.md` with `name` and
`description` frontmatter, and `name` matches the parent directory. That
keeps them portable across any tool that reads the spec.

## What's inside

```
agent-skills/
├── skills/
│   ├── expert-review-panel/      # 10-expert iterative review until score ≥ 90/100
│   ├── requirements-interview/   # Structured requirements interview before coding
│   ├── finish/                   # Take an open PR through review → fixes → push
│   └── ship/                     # Implement → expert review → open PR → triage feedback
├── commands/
│   ├── open-pr.md                # Commit to a feature branch and open a PR
│   ├── pr-review.md              # Pull and prioritize PR comments
│   └── tag-reviewers.md          # Tag @claude and @codex on the current PR
└── hooks/
    ├── expert-review-gate.sh         # Stop hook: block if files changed since last expert review
    ├── expert-review-pre-skill.sh    # PreToolUse: mark expert-review-panel as pending
    ├── expert-review-post-skill.sh   # PostToolUse: record reviewed-tree hash
    └── ruff-check-gate.sh            # Stop hook: block if ruff lint/format fails
```

## Why

Skills/commands/hooks evolve faster than any one project. Keeping them in a
public repo means:

- **Multi-machine portability.** Point Blocks' Global Configuration Repository
  setting at this repo and every workstation inherits the same setup.
- **Sharable defaults.** A teammate or stranger can clone or copy individual
  files instead of reverse-engineering them from a screenshot.
- **Versioned tweaks.** When `expert-review-panel` gets a better expert lineup,
  the diff lives in git history rather than a chat transcript.

## Install

### Claude Code

Pick whichever you prefer:

```bash
# Option A — clone and symlink the whole tree (everything stays in sync)
git clone https://github.com/joejansen/agent-skills.git ~/code/agent-skills
ln -s ~/code/agent-skills/skills/expert-review-panel    ~/.claude/skills/
ln -s ~/code/agent-skills/skills/requirements-interview ~/.claude/skills/
ln -s ~/code/agent-skills/skills/finish                 ~/.claude/skills/
ln -s ~/code/agent-skills/skills/ship                   ~/.claude/skills/
ln -s ~/code/agent-skills/commands/open-pr.md           ~/.claude/commands/
ln -s ~/code/agent-skills/commands/pr-review.md         ~/.claude/commands/
ln -s ~/code/agent-skills/commands/tag-reviewers.md     ~/.claude/commands/

# Option B — copy individual items (you'll need to re-copy on updates)
cp -r skills/finish ~/.claude/skills/
```

### Blocks

Settings → **Global Configuration** → "Global configuration repository" →
select `joejansen/agent-skills` (or your fork). Skills, hooks, and sub-agents
load from the repo at runtime — no file copying required.

### Codex

Codex auto-loads skills from a few [`.agents/skills/` locations](https://developers.openai.com/codex/skills),
checked in this order of precedence:

1. `$CWD/.agents/skills` (walking up to the repo root)
2. `$REPO_ROOT/.agents/skills`
3. `$HOME/.agents/skills`
4. `/etc/codex/skills`

The simplest install is a single symlink at user scope so every project
inherits these skills:

```bash
git clone https://github.com/joejansen/agent-skills.git ~/code/agent-skills
mkdir -p ~/.agents
ln -s ~/code/agent-skills/skills ~/.agents/skills
```

Or per-repo, if you want a project to bundle them:

```bash
mkdir -p /your/project/.agents
ln -s ~/code/agent-skills/skills /your/project/.agents/skills
```

Codex matches skills implicitly via the `description` field, so each skill's
description should clearly state when it should and shouldn't trigger.

### Hooks

Hooks aren't loaded automatically — they're scripts you wire into your
`settings.json`. See [`hooks/README.md`](hooks/README.md) for a copy-pasteable
example.

## Skills index

| Skill | Trigger | What it does |
| --- | --- | --- |
| `expert-review-panel` | "review with experts", "iterate until perfect" | 10 experts (architect, security, performance, DB, API, UX, SRE, code quality, domain, maintainability) score the change and iterate until the average passes the threshold (default 90/100). |
| `requirements-interview` | "interview me", "spec out", "help me think through" | Structured 5-phase interview (foundation → technical → UX → risks → tradeoffs) using the AskUserQuestion tool to surface blind spots before any code is written. |
| `finish` | `/finish <PR-NUMBER>` | Checks out a PR, reviews it, runs CI and tests, addresses review comments, replies, pushes fixes, re-checks. |
| `ship` | invoked after a plan is approved | Implements → expert-review → opens PR → optionally tags external reviewers → triages feedback → reports. |

## Commands index

| Command | What it does |
| --- | --- |
| `/open-pr` | Ensure all changes are committed to a feature branch and open a PR. |
| `/pr-review` | Pull all PR comments and prioritize them; address critical/high/medium and reply on the PR. |
| `/tag-reviewers` | Tag `@claude` and `@codex` on the current branch's PR for an external review. |

## Customizing

Two skills (`finish` and `ship`) reference your test command via a
`<your test command>` placeholder. The cleanest way to make this portable is
to record the canonical test invocation in your project's `CLAUDE.md` or
`AGENTS.md` so the agent can read it on demand. If you fork this repo, you
can also hardcode the placeholder to your usual command.

The `ruff-check-gate.sh` hook is a Python/ruff example — copy the pattern for
`pytest`, `eslint`, `mypy`, `cargo clippy`, etc. The structure (git-root cd,
tool-presence check, exit 2 on failure) is the load-bearing part.

## License

MIT — see [LICENSE](LICENSE).
