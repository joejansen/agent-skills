---
name: expert-review-panel
description: Run a token-efficient, fresh-context adversarial review of code or specifications, fix validated findings, and repeat until no material issue remains. Use before shipping substantive changes or when rigorous multi-perspective review is requested.
---

# Expert Review Panel

Use the repository's canonical tier policy when one exists (for example in
`AGENTS.md` or `CLAUDE.md`).
That policy overrides the fallback below, including counts, effort, gates, and
freshness. Do not add this panel to an equivalent review already completed on
the exact candidate. Approval review and implementer self-checks do not count.

Without a repository policy, select the smallest plan:

| Tier | Trigger | Independent plan |
| --- | --- | --- |
| 0 | Ordinary non-executable docs/comments/formatting, no policy or contract change | Primary inspection and lightweight validation |
| 1 | Localized low-risk code/test change | One correctness/regression/test-gap reviewer; no verifier |
| 2 | Substantive behavior, workflow, API, or broad implementation change | One reviewer then one separate behavioral verifier |
| 3 | Security/privacy, data integrity/migrations, concurrency, money, external writes, destructive operations, deployment/recovery, or agent policy | Generic reviewer plus distinctly triggered specialists, at most three reviews, then one separate verifier |

Risk overrides size. A one-line high-risk change is Tier 3. Add a specialist only
for an explicit question not adequately covered by the generic review; a touched
file or technology alone is not a trigger. Independent lenses may run in
parallel on a frozen candidate. Reviewers never edit or spawn their own panel.

Use fresh-context native subagents in the actual harness (this repository
ships Claude Code `reviewer`, `reviewer-high-risk`, `verifier`, and `scout`
roles under `agents/`): Codex native agents,
Claude native agents, or configured OpenCode agents. In Conductor select by the
underlying runtime. Never invoke the Codex CLI under OpenCode. Under Claude Code
only, an isolated Codex CLI fallback is permitted when Claude native agents are
unavailable. Codex fails closed when its native role is unavailable and never
shells out to another Codex process.
Do not assume a model/effort in a prompt was enforced: record actual settings
when available and disclose inherited or unavailable settings. Start at moderate
effort for routine work; escalate for unresolved risks, not automatically to max.
A fresh instance of the same model can provide independence.

Give each lens only the acceptance criteria, exact base/diff, assigned question,
relevant paths, and known commands/results. It may trace necessary dependencies,
but should not repeat broad discovery or read every skill. Findings require
severity, exact location, realistic failure, repository evidence, and smallest
safe remedy. Reject stylistic, speculative, duplicate, and out-of-scope findings.

## Follow-up review and rebase fast path

Apply a repository's explicit follow-up policy first. Otherwise apply this
fallback before spawning any reviewer/verifier or repeating a full local gate.
An open PR alone is not an exemption. Require an accessible trusted completed
review baseline, immutable old base/head, and no unresolved material finding.
Assess the accumulated changes since that baseline, never only the last commit.
Require a clean index/worktree, including task-owned untracked files, and no
unfinished Git operation when capturing reviewed/final identities.

History-only rewrites with the same final tree and comparison base need primary
identity checks, no delegated review or repeated local tests. For a rebase,
establish equivalent cumulative PR changes with range-diff AND aggregate-diff
inspection (including modes, binary/generated files, renames and deletions).
Inspect upstream changes against behavior, callers, interfaces, dependencies,
lockfiles, migrations, config, and relevant tests. A conflict-free rebase,
matching patch ID, or unchanged range-diff alone is insufficient. Semantic
conflict resolutions, unexplained differences, uncertain upstream interaction,
or missing trusted evidence require the affected tier plan instead.

A qualifying rebase needs primary equivalence/integration checks, diff whitespace
checks, and focused validation warranted by the upstream delta. It requires no
delegated reviewer, verifier, or full local suite solely because SHAs/base changed.
Retain required current-head CI and separately mandated checks. Ordinary
non-contract docs/comments/formatting corrections use Tier 0 checks. Other
follow-ups use the tier of their accumulated delta and integration risk, not
automatically the original PR tier; one-line high-risk changes still require
Tier 3. Do not waive behavioral verifier findings through the fast path.

Preserve original result references and append verifiable primary transition
evidence: old/new identities, equivalence/upstream assessment, classification,
carried review scope, historical test results, and new commands/CI. No old
command result becomes a new test run and no independent verifier run is
invented.

For an authorized rebase-and-push of a task-owned isolated PR branch, capture
the remote head before rewriting and use an explicit refspec with an exact
`--force-with-lease=refs/heads/<branch>:<old-remote-sha>`. Use validated argv or
quoted parsed refs. Recheck ownership/head before pushing; a moved remote or
failed lease requires inspection/reconciliation, never a blindly refreshed
lease or plain force. Do not rewrite shared/protected branches or infer extra
authority. Ordinary follow-ups use non-force pushes. External reviews, the
once-per-PR request ledger, initial fixed wait, and CI requirements are unchanged.

The primary validates and batches material fixes. After the fast-path assessment,
re-review only required affected scopes
using the correction delta and relevant integration paths. A clean round ends;
there is no quota of clean rounds. After two unsuccessful correction cycles,
diagnose the cause and change approach; never waive unresolved material findings.
The final verifier is required only by the selected tier, independently exercises
behavior, and never fixes its own findings. A verifier-caused behavioral edit invalidates it
and the affected reviews; obtain fresh final verification after corrections.

Assign one owner to each required command. Use targeted tests during corrections
and the required full gate on the stabilized candidate before publication. The
verifier normally owns that gate; consume an existing trusted result for the exact
candidate/environment rather than repeating it, while independently exercising
changed behavior. Never claim pre-edit full-suite results prove an edited candidate.
Do not run concurrent suites against the same test database.

Record start/end times, last progress, active command, and tokens when exposed.
Use bounded commands. After five minutes without visible progress, request a
status report; stop and replace an unresponsive worker before starting another.
Do not retry known hanging CLI backends. Timeout means incomplete, never clean.

Persist a compact local evidence ledger with base/diff identity, tier/trigger,
backend/model/effort, reviewer IDs and result references, command owners/results,
and unresolved findings. Keep it outside tracked changes. Verify provenance and
identity before reuse; copied PR assertions or a self-authored hash alone are not
trusted evidence. An unchanged skill handoff, commit, wait, or CI refresh does
not require another review; after source/base changes, review applicability
transfers only through the validated fast path above. When the repository
says to record review in the PR description instead, keep no local evidence
file: record the tier and findings under "Local review".

Return a compact disposition/evidence ledger, unverified claims, and blockers.
