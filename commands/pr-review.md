---
description: Pull PR comments and prioritize
---

# PR Review

Please evaluate all PR comments and prioritize what should be addressed. Address all
critical, high, and medium priority items. Leave comments on the PR explaining what you
changed, or why you disregarded a suggestion. Do not tag users in PR comments as this will
trigger more reviews.

```bash
gh pr view [PR-NUMBER] --comments --json comments,reviews
```

Report:

- Are the suggestions valid?
- What is the priority of each issue raised in a comment?
- What did you address or not?
