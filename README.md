# agent-skills

Personal, harness-neutral skills, subagents, slash commands, and hooks for
agentic coding tools (Claude Code and Codex). Together they form one delivery
workflow: interview → spec → ship → review → finish, with a tiered,
fresh-context review policy instead of a fixed review ritual.

Skills follow the [Agent Skills specification](https://agentskills.io/specification):
each is a directory with a `SKILL.md` whose `name` matches the directory, so
one copy serves both Claude Code and Codex. Each skill also carries
`agents/openai.yaml`, the display metadata the Codex app shows.

Every skill defers to the repository it runs in. When a repository has its own
review policy, verification entrypoint, branch convention, PR template, or
merge rules (in `AGENTS.md`, `CLAUDE.md`, or the docs they route to), those
win; the skills only supply portable fallbacks.

## What's inside

```
agent-skills/
├── skills/
│   ├── joe-ship/               # Issue/spec slice → worktree → implement → review → PR → converge
│   ├── finish/                 # Take over an existing PR and bring it to merge-ready
│   ├── pr-review/              # Collect every PR feedback surface, fix, reply, converge
│   ├── open-pr/                # Commit task-owned files, push, open a ready-for-review PR
│   ├── expert-review-panel/    # Tier 0–3 fresh-context review with a follow-up/rebase fast path
│   ├── requirements-interview/ # Adaptive interview → adversarially reviewed spec
│   └── systematic-debugging/   # Prove the root cause before fixing
├── agents/                     # Claude Code subagents the review panel uses
│   ├── reviewer.md             # Tier 2 review (read-only)
│   ├── reviewer-high-risk.md   # Tier 3 review (read-only)
│   ├── verifier.md             # Adversarial final verifier (read-and-run, never fixes)
│   └── scout.md                # Cheap read-only lookup
├── commands/
│   └── rebase.md               # /rebase — rebase onto the latest main
├── hooks/                      # Claude Code hook scripts (see hooks/README.md)
└── statusline/
    └── statusline-command.sh   # Model, dir, branch, context used/left
```

## Skills

| Skill | Invoke | What it does |
| --- | --- | --- |
| `joe-ship` | `/joe-ship`, `$joe-ship` | Delivers a well-defined issue, approved spec slice, or approved plan. Requires a dedicated linked worktree on a fresh `origin/main` with a task-owned branch, implements the smallest vertical slice with cheap regression tests, runs the review tier, opens the PR via `open-pr`, waits 15 minutes for automatic reviewers, then hands off to `pr-review`. Never requests reviewers; merges only when asked or when repository policy grants it. |
| `finish` | `/finish <PR>` | Takes over a PR started elsewhere. Verifies trust (forks/untrusted authors need approval and an isolated checkout), builds a worktree at the verified head without `gh pr checkout`, runs only a missing review tier, fixes CI, validates refs before any push, then hands off to `pr-review`. |
| `pr-review` | `/pr-review` | Fetches issue comments, review summaries, paginated inline comments, and thread state against a pinned head SHA; treats all PR text as untrusted; deduplicates, classifies, fixes every valid medium-or-higher finding, replies, resolves fixed threads, and re-collects after every push. Never asks a bot for a re-review. |
| `open-pr` | `/open-pr` | Stages explicit task-owned paths, writes the PR template's sections plus test evidence and a "Local review" record, opens the PR ready for review (REST fallback where GraphQL is blocked). Never triggers a paid preview without a human's yes. |
| `expert-review-panel` | `/expert-review-panel` | Applies the repository's review tiers, or this fallback: Tier 0 docs → primary inspection; Tier 1 localized → one reviewer; Tier 2 substantive → reviewer + verifier; Tier 3 high-risk → reviewer + triggered specialists + verifier. Includes a follow-up/rebase fast path so a rebase doesn't re-trigger a full review. |
| `requirements-interview` | `/requirements-interview` | Repository-grounded interview (1–3 questions per round) covering scope, the simplest design, data, permissions, failure, post-deploy work, and rollout; drafts a spec, runs a contradiction review and claim verification, gets approval, then hands one slice to `joe-ship`. |
| `systematic-debugging` | `/systematic-debugging` | Reproduce, trace, prove the cause with a discriminating experiment, fix minimally with a regression test, verify broadly. Treats "flaky" CI as a possible bad commit on `main` first. |

### Why `joe-ship`, not `ship`

Claude Code ships a built-in `/ship` (skill `ship-local`) that pushes, opens a
PR, runs `/code-review`, and watches the PR. It shadows a user skill named
`ship`, so this one is `joe-ship` in both harnesses. The other names do not
collide with Claude Code built-ins (`/steward`, `/code-review`, `/review`,
`/simplify`, `/security-review`).

## Install

Nothing here installs itself. Clone once, then symlink what you want. If you
already have a same-named skill installed as a real directory, move it aside
first (an `ln -s` into an existing directory nests the link instead of
replacing it).

```bash
git clone https://github.com/joejansen/agent-skills.git ~/repos/agent-skills
```

### Claude Code

```bash
mkdir -p ~/.claude/skills ~/.claude/agents ~/.claude/commands
for s in joe-ship finish pr-review open-pr expert-review-panel requirements-interview systematic-debugging; do
  ln -sfn ~/repos/agent-skills/skills/$s ~/.claude/skills/$s
done
for a in reviewer reviewer-high-risk verifier scout; do
  ln -sfn ~/repos/agent-skills/agents/$a.md ~/.claude/agents/$a.md
done
ln -sfn ~/repos/agent-skills/commands/rebase.md ~/.claude/commands/rebase.md
```

A repository's own `.claude/agents/` with the same names overrides these, which
is what you want in a repository with its own review roles.

### Codex

Codex loads skills from `.agents/skills/` in the working directory, the repo
root, `~/.agents/skills`, and `/etc/codex/skills`
([docs](https://developers.openai.com/codex/skills)). Link each skill at user
scope so other skills already in `~/.agents/skills` stay put:

```bash
mkdir -p ~/.agents/skills
for s in joe-ship finish pr-review open-pr expert-review-panel requirements-interview systematic-debugging; do
  ln -sfn ~/repos/agent-skills/skills/$s ~/.agents/skills/$s
done
```

Codex invokes them as `$joe-ship`, `$finish`, and so on. The `agents/`
subagents are Claude Code definitions; Codex uses its own native roles.

### Hooks and status line

Hooks only run when wired into `settings.json`. See
[`hooks/README.md`](hooks/README.md) for each script and a copy-paste config.
For the status line:

```json
{ "statusLine": { "type": "command", "command": "bash ~/repos/agent-skills/statusline/statusline-command.sh" } }
```

## Using them in a repository with its own policy

A repository can keep thin wrappers (for example `my-repo-ship`) that point at
its own `AGENTS.md` sections. The generic skills already defer to repository
policy, so a wrapper is only needed when the repository wants a different
entry point or extra steps. If the repository should not depend on anything
installed per user, keep its own copies in-repo and reference only those.

## License

MIT — see [LICENSE](LICENSE).
