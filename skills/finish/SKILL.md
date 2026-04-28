---
name: finish
description: Finish an open PR — check out the branch, review code quality, check CI, pull and address PR comments, push fixes. Usage: /finish <PR-NUMBER>
user_invocable: true
---

# Finish PR

Take an already-opened pull request through final review, comment triage, fixes, and push. This is for PRs that are open but need a human-quality once-over before merge.

## Input

The user provides a PR number as an argument (e.g., `/finish 160`). If no number is provided, ask for one.

## Step 1: Check Out the Branch and Understand the PR

1. Get PR metadata and diff:
   ```bash
   gh pr view <PR_NUMBER> --json title,body,headRefName,baseRefName,changedFiles,additions,deletions,state
   gh pr diff <PR_NUMBER>
   ```
2. Check out the branch:
   ```bash
   gh pr checkout <PR_NUMBER>
   ```
3. Read the changed files to understand what the PR does.

## Step 2: Check CI Status

```bash
gh pr checks <PR_NUMBER>
```

- If CI is failing, investigate the failure. Fix it if straightforward, then push and re-check.
- If CI is passing, proceed.
- If CI is still running, note it and proceed — you'll re-check later.

## Step 3: Code Review

Review the PR diff with a critical eye. Evaluate:

- **Is this change worthwhile?** Does it improve the codebase, or is it churn?
- **Correctness**: Does the logic do what it claims? Any bugs or edge cases?
- **Test coverage**: Are new behaviors tested? Are existing tests still valid?
- **Style and conventions**: Does it follow project conventions (CLAUDE.md)?
- **Safety**: Any security, data integrity, or migration concerns?

If the changes are not worthwhile (net negative or pure churn), stop and tell the user — recommend closing the PR with a reason.

If the changes are good but need improvements, note what to fix and proceed.

## Step 4: Pull and Prioritize PR Comments

Invoke the `/pr-review` skill to pull all PR comments and prioritize them.

This will:
- Fetch all review comments from GitHub (human reviewers, @claude, @codex, CI)
- Categorize by priority (critical, high, medium, low)
- Produce an action list

## Step 5: Address Issues

Work through all issues in priority order:

1. CI failures (from Step 2)
2. Critical and high priority PR comments (from Step 4)
3. Issues found in your own code review (from Step 3)
4. Medium priority PR comments

For each fix:
- Make the change
- Run the project's test suite to confirm nothing broke. The exact command varies by project — check `CLAUDE.md`, `AGENTS.md`, or `README.md` for the canonical test invocation. Examples:
  ```bash
  # <your project's test command — e.g., `npm test`, `pytest`, `cargo test`,
  # or a Django test target. Define it in CLAUDE.md so this skill stays portable.>
  ```

Skip low-priority nitpicks unless they're trivial one-liners.

## Step 6: Push and Respond

1. Commit and push fixes (if any were made):
   ```bash
   git add <changed-files>
   git commit -m "<descriptive message>"
   git push
   ```

2. For each PR comment that was addressed, reply on the PR explaining what was changed:
   ```bash
   gh pr comment <PR_NUMBER> --body "Addressed review feedback: ..."
   ```

3. For any comment you intentionally skipped, reply explaining why.

## Step 7: Final Check

1. Wait 2 minutes for CI to pick up the new push
2. Re-check CI:
   ```bash
   gh pr checks <PR_NUMBER>
   ```
3. If CI fails, fix and push again (max 2 retry loops)
4. Check for any new comments that arrived:
   ```bash
   gh pr view <PR_NUMBER> --json comments,reviews --jq '[.comments | length, .reviews | length] | add'
   ```

## Step 8: Report

Report final status to the user:

- PR title and URL
- CI status (green/red)
- Summary of what was reviewed and changed
- Any outstanding items the user should decide on
- Whether the PR is ready to merge
