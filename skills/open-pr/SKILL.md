---
name: open-pr
description: Publish a verified local changeset by creating a feature branch if needed, committing only task-owned files, pushing, and opening a clear pull request. Use when asked to open a PR or as the publishing step of ship.
---

# Open PR

Before the ordinary stage gates below, apply the repository's follow-up policy
or `$expert-review-panel` **Follow-up review and rebase fast path**. Qualifying
mechanical follow-ups do not spawn reviewers/verifiers or repeat a full local
gate. Preserve trusted review lineage and current CI; other follow-ups use the
accumulated delta and integration risk.

Read repository contribution and PR instructions. Confirm the diff contains
only intended changes and that tier-required verification is current. Consume
trusted current review/test evidence; opening a PR never adds a review or reruns
a gate. Follow repository policy or the `$expert-review-panel` fallback. Create a
properly named feature branch when needed. Stage explicit task-owned paths,
never `git add .`, and use a concise commit message without false co-author
attribution.

Push the branch and open a PR with the sections the repository's PR template
requires (`gh pr create --body` bypasses the template, so write them
yourself), plus:

- outcome-oriented title;
- context, implementation summary, and scope/non-goals;
- exact test and manual verification evidence;
- migration, rollout, rollback, security, and screenshot notes when relevant;
- linked issue or approved spec/slice;
- the review tier and what local review found (lenses, findings,
  dispositions, verifier result) under "Local review".

Open the PR ready for review so automatic reviewers run. Use a draft only when
the user explicitly requests one or a concrete, documented blocker makes
meaningful review premature. `gh pr create` uses GraphQL; where the host blocks
it, create the PR with the REST pulls API instead.

Follow the repository's preview-environment guidance. Trigger a paid or shared
preview deployment (a title marker, label, or command) only when a human
explicitly requests one for that PR or confirms yes after being asked. UI
changes, new features, or significant scope alone are not approval; an existing
explicit request for that PR needs no further confirmation. Note the approval
in the PR description when enabling a preview.

In a repository that defers full CI until review converges, a standalone
publication reports that deferred state and names `$pr-review` as the step
that requests it; never claim CI passed. Return the PR URL, branch, head SHA, and whether the PR is
draft or ready. Do not merge.
