---
name: joe-ship
description: Ship a well-defined issue, approved spec slice, or approved plan through implementation, verification, PR creation, and review convergence. Use when the user says ship or asks for end-to-end delivery of scoped work.
---

# Ship

Before the ordinary stage gates below, apply the repository's follow-up policy
or `$expert-review-panel` **Follow-up review and rebase fast path**. Qualifying
mechanical follow-ups do not spawn reviewers/verifiers or repeat a full local
gate. Preserve trusted review lineage and current CI; other follow-ups use the
accumulated delta and integration risk.

Own the work through a merge-ready pull request. Do not stop at implementation
or PR creation while a safe, relevant verification or review step remains.

## Worktree gate

Every ship workflow must be carried out in a dedicated linked Git worktree for
the task, based on the latest fetched `origin/main`. A normal checkout,
including the repository's primary checkout, is not an acceptable ship
workspace.

Before reading or editing task-owned issue, specification, implementation, or
test files, read only the agent/repository policy instructions needed to apply
this gate, then always refresh the base and determine whether the session is
already in a task-owned linked worktree. Those initial policy instructions may
be read in the current checkout; task-owned files must not be read or edited
there.

```bash
git fetch origin main:refs/remotes/origin/main
fetched_base_sha="$(git rev-parse --verify --quiet 'FETCH_HEAD^{commit}')"
origin_main_sha="$(git rev-parse --verify --quiet 'refs/remotes/origin/main^{commit}')"
test "$fetched_base_sha" = "$origin_main_sha"
```

The fetch must exit successfully before any other gate check. If it fails, stop
and do not qualify the session or use the cached `origin/main`. Run every check
below in the same shell/session while retaining the captured SHA values; a
failed command, empty result, or mismatch is a failed gate, not permission to
continue. Never replace `fetched_base_sha` with a later read of mutable
`origin/main`.

For an existing worktree, verify the workspace and base objectively before
accepting it:

```bash
git worktree list --porcelain
git rev-parse --show-toplevel
git branch --show-current
git rev-parse --path-format=absolute --git-dir
git rev-parse --path-format=absolute --git-common-dir
git symbolic-ref --short --quiet refs/remotes/origin/HEAD
git rev-parse --verify --quiet 'refs/remotes/origin/HEAD^{commit}'
git merge-base "$fetched_base_sha" HEAD
```

The current top-level path must appear as a non-primary linked `worktree`
entry, and the resolved Git directory must be beneath the common Git directory's
`worktrees/` directory. Do not infer linked-worktree status from whether
`.git` is a file: a primary checkout made with `--separate-git-dir` can also
have a `.git` file. The remote default-branch symbolic ref must resolve, and
its target object must exist; a dangling symbolic ref is unconfirmed. The
current branch must not be that default. Define task ownership with the
branch name, not a guess about the agent runtime: unless repository policy
defines an equivalent convention that includes task identity (some policies
also accept a branch the harness created for this session's own worktree,
which must still pass every other check here), use
`ship/<task-id>-<short-slug>`, where `<task-id>` is the approved issue number,
spec identifier, or plan identifier. The current branch must exactly match the
selected task's name under that convention, must not be checked out in another
worktree, and must not be listed by repository or hosting policy as protected
or shared. If the task-to-branch match or protected/shared classification
cannot be established from authoritative task and repository/hosting context,
treat the existing worktree as unconfirmed rather than reusing it. A missing
repository policy or unavailable read-only hosting lookup is unknown status,
not approval. The `merge-base` output must match the captured
`fetched_base_sha`; the earlier equality check proves `FETCH_HEAD` and
`origin/main` identify the same fetched object. Treat any missing or mismatched
result as an unconfirmed base. Preserve the existing worktree and task changes;
create a fresh task worktree from the fetched base and deliberately port the
task-owned changes there before continuing. Never delete, reset, or silently
abandon the previous work.

If it is not, leave the current checkout untouched and create a new worktree
and task branch from that freshly fetched ref:

Choose an unused `<task-branch>` using the exact task-identity convention above
or an equivalent repository convention; do not infer a branch prefix from the
agent runtime. Before using a name, confirm that neither its local branch ref
nor its `origin` remote branch ref exists (a no-match result is acceptable; a
lookup or network error is not). A fresh task-specific name with no local or
remote ref is the objective ownership check for a new branch; reject any name
listed as protected/shared by repository or hosting policy. If ownership or
that classification is unknown, choose another fresh task-specific name or
stop rather than publish to an existing branch. Do not reset or overwrite a
branch with `-B`; choose another unused name or use its qualifying linked
worktree. The new path must not already exist, must not be the current checkout
or a descendant of it, and must not be inside any other listed worktree. Resolve
and compare the path boundaries before running `git worktree add`; if that
cannot be confirmed, choose a different unused sibling path. This keeps the
original checkout untouched.

Before `git worktree add`, use these read-only ref lookups for the selected
task branch:

```bash
git show-ref --verify --quiet refs/heads/<task-branch>
git ls-remote --exit-code --heads origin <task-branch>
```

For each lookup, a no-match status means the ref is unused; a matching ref
means the name is occupied. Any other lookup or network error is a failed gate.

After those checks pass, create the new worktree and task branch from the
freshly fetched ref:

```bash
git worktree add -b <task-branch> <new-worktree-path> "$fetched_base_sha"
```

Continue the entire ship workflow from the new worktree. If the session is
already in a task-owned linked worktree, use it only after the checks above
confirm that it is linked and its branch base matches the freshly fetched
`origin/main`; do not create a nested worktree. If that base cannot be
confirmed, create a replacement linked worktree from the freshly fetched
`origin/main` before editing. Preserve unrelated changes in the original
checkout and never run ship implementation, tests, commits, or PR preparation
there. A branch or worktree that merely exists, or that cannot be tied to this
task, is not a qualifying reuse candidate.

## Entry gate

1. Read repository instructions and relevant routed documentation.
2. Identify the issue, approved spec/slice, or approved plan and list its
   measurable acceptance criteria.
3. Inspect the actual code paths and tests before editing.
4. If material behavior, scope, or architecture is unresolved, invoke
   `$requirements-interview`. Do not guess past a blocking spec question; for
   a spec slice, read the whole spec and do not start a slice an open
   question affects.
5. State the implementation boundary, the simplest approach that fully meets
   the acceptance criteria (a new table, setting, screen, abstraction, or
   human step needs a stated reason), and the cheapest tests that prove it.
6. Preserve unrelated changes and stage only task-owned paths.

## Implement

Use one coherent implementer for coupled changes. Delegate only bounded,
independent read-only discovery or review work. Implement the smallest coherent
vertical slice and run narrow tests after each behavior change. Add the cheapest
regression coverage that fails without the fix, following the repository's
test-cost policy; prefer extending an existing test or fixture. Trace every
sibling surface the task names. For UI work, exercise the real browser flow
and keep screenshot evidence for the PR the way the repository says (some
repositories forbid committing screenshots).

Use the repository's verification entrypoint when it has one, preferring its
targeted and full gates over copied command lists.

A step a person must do by hand in production is designed away when code can
do it (a data migration, a deploy hook, or a self-pacing background job that
stops on an explicit condition). One that remains becomes an assigned issue
linked from the PR; if it must happen before the deploy, do not merge until it
closes.

When the change alters behavior that the repository's agent guidance documents
(for example `CLAUDE.md`, `AGENTS.md`, or the docs and rules they route to),
edit that text in place so it states the current rule: replace or prune stale
text, and never append a per-issue history bullet. Follow the repository's
documentation size and placement rules when it has them.

## Local adversarial gate

1. Apply the repository's canonical review tier. Only in a repository with no
   review policy, use the `$expert-review-panel` fallback, where ordinary docs
   need no delegated reviewer and routine low-risk changes need one reviewer and
   no verifier.
2. Invoke the panel only for missing or stale required evidence. Use native
   subagents and moderate starting effort; do not run duplicate review mechanisms.
3. Batch validated material fixes, run affected tests, and re-review affected
   scopes using the correction delta and necessary integration paths.
4. Assign one owner to the tier-required full gate on the stabilized candidate.
   The final verifier normally owns it; consume trusted current results without
   repeating the suite. A verifier is required only when the tier says so.
5. Record the tier and what local review found (lenses, findings,
   dispositions, verifier result) in the PR description under "Local review".

## Publish and converge

Invoke `$open-pr` and open the PR ready for review unless the user explicitly
requested a draft or a concrete, documented blocker makes meaningful review
premature. Follow the repository's preview-environment guidance: never
trigger a paid or shared preview deployment (a title marker, label, or
command) unless a human explicitly requested or confirmed one for that PR. UI
or substantial feature work alone does not authorize a preview. Let automatic
reviewers run when the ready PR opens. Never
request bot re-review after later pushes, fixes, or replies.

Do not request reviewers. Reviewer requests belong to repository automation
(for example a workflow that posts review requests when the PR opens); agents
never post them.

Wait until a full 15 minutes have elapsed from the PR's ready timestamp before
invoking `$pr-review`. Use the available wait or monitoring mechanism; CI
observation may continue concurrently. Do not end the window early when
feedback arrives, and do not reset or extend it for later activity. When it
expires, proceed with the feedback available even if an external review has
not arrived.

Then invoke `$pr-review`, which owns feedback validation, fixes, replies,
verification, pushes, and convergence without requesting bot re-reviews.
Consume its final ledger instead of repeating that loop. An arbitrary retry cap
is not a completion condition. In a repository that defers full CI until review
converges, `$pr-review` also makes the policy's final-CI request.

Report the PR URL, head SHA, verification evidence, non-blocking reviewer
status, feedback dispositions, any human-step issue opened and its assignee,
and any real blocker. Do not merge unless
explicitly requested or the repository's agent policy grants merge authority
to a completed run.
