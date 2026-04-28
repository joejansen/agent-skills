---
description: Tag claude and codex reviewers
---

# Tag PR Reviewers

On the current branch that has an open PR, run the following commands:

```bash
gh pr comment <PR_NUMBER> --body "@claude please review this PR"
gh pr comment <PR_NUMBER> --body "@codex please review this PR"
```
