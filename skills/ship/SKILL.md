---
name: ship
description: Automated feature shipping pipeline — implement, review, and open PR
user_invocable: true
---

# Ship

Automated pipeline that takes an approved plan through implementation, expert review, and PR creation.

## Prerequisites

- A plan must exist in the current conversation (from plan mode or user description). If no plan exists use the requirements-interview skill to gather requirements and create a plan before invoking this skill.
- Dev server running is recommended for UI verification

## Step 1: Implement the Plan

1. Confirm what to implement — if no plan was discussed in this conversation, ask the user what to build using the requirements-interview skill.
2. Implement the plan following project conventions.
   - Reference `CLAUDE.md` (or `AGENTS.md`) for full conventions.
3. After each logical chunk of changes, run the project's test suite.
4. If tests fail, fix and re-run until all pass.
5. Continue until every plan item is complete and the full test suite is green.
6. Stage all changes but do NOT commit yet.

## Step 2: Expert Review Panel

1. Invoke the `/expert-review-panel` skill
2. The panel runs 10 expert reviews and iterates until the average score reaches the threshold (default: 90/100)
3. The expert-review pre/post hooks will track review state automatically (see `hooks/` in the agent-skills repo)
4. If the review suggests changes, apply them and re-run the test suite to confirm nothing broke

## Step 3: Open PR

1. Invoke the `/open-pr` skill to commit changes to a feature branch and create the pull request
2. Report the PR URL to the user

## Step 4: Complexity Gate — Tag External Reviewers (or skip)

After the PR is created, assess whether external agent reviews are warranted.

**Run this check using `gh`:**

```bash
# Get file count and line counts from the PR metadata
gh pr view <PR_NUMBER> --json changedFiles,additions,deletions

# Get the list of changed file names
gh pr diff <PR_NUMBER> --name-only
```

**Tag @claude and @codex when ANY of these are true:**

- 3 or more files modified (`changedFiles >= 3`)
- 100 or more lines changed (`additions + deletions >= 100`)
- The change touches DB schema, public APIs, or routing — adapt the file globs to your project (e.g., `/migrations/`, `models.py`, `urls.py` for Django; `schema.prisma`, route files for Next.js; etc.)

If none of these trigger, skip to Step 5 (wait for reviewers).

**When tagging:**

```bash
gh pr comment <PR_NUMBER> --body "@claude please review this PR"
gh pr comment <PR_NUMBER> --body "@codex please review this PR"
```

## Step 5: Wait for External Reviews

1. Wait 10 minutes for the external agents to post their reviews
2. After waiting, check that reviews have landed:
   ```bash
   gh pr view <PR_NUMBER> --json comments,reviews --jq '[.comments | length, .reviews | length] | add'
   ```
3. If no new comments appeared after 10 minutes, proceed anyway — the agents may be unavailable

## Step 6: Pull and Prioritize PR Comments

1. Invoke the `/pr-review` skill to pull PR comments and prioritize them
2. This reads all review comments (from @claude, @codex, gemini, copilot) and produces a prioritized action list

## Step 7: Address Feedback

1. Work through the prioritized comment list from Step 6
2. Fix CI failures first, then address review comments in priority order
3. Run the project's test suite after changes — the exact command varies by project; see `CLAUDE.md` or `AGENTS.md`. Examples:
   ```bash
   # <your project's test command — e.g., `npm test`, `pytest`, `cargo test`,
   # or a Django test target. Define it in CLAUDE.md so this skill stays portable.>
   ```
4. Push the fixes: `git push`

## Step 8: Re-check

1. After pushing, wait 3 minutes for CI to run
2. Check CI status: `gh pr checks <PR_NUMBER>`
3. Check for new review comments: `gh pr view <PR_NUMBER> --json comments,reviews --jq '[.comments | length, .reviews | length] | add'`
4. If CI fails or new comments arrived, go back to Step 6
5. Maximum 3 feedback loops — if still not clean after 3 rounds, stop and report status to the user

## Step 9: Done

1. Report final status to the user:
   - PR URL
   - CI status (green/red)
   - Outstanding review comments (if any after 3 rounds)
   - Whether external reviewers were tagged or skipped (and why)
2. The user decides whether to merge
