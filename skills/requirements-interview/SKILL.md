---
name: requirements-interview
description: Conduct a deep, adaptive requirements interview and produce a repository-grounded, adversarially reviewed implementation spec. Use for ambiguous features, architecture choices, large fixes, spec writing, or when the user asks to be interviewed.
---

# Requirements Interview

Keep requirements, tradeoffs, and decisions in the primary conversation. Use
read-only scouts to verify repository facts; never delegate the interview or
final synthesis.

## Interview

Start by inspecting repository guidance, related code, existing specs, and
tests so questions are informed rather than generic. Ask one to three focused
questions per round and adapt to each answer. Periodically summarize decisions,
assumptions, and unresolved points for correction.

Cover only relevant dimensions, but do not omit a material one:

- problem, users, workflows, success measures, scope, and non-goals;
- the simplest design that fully meets the need: what is deliberately not
  built, and the reason for each new table, setting, screen, or abstraction;
- current behavior and compatibility commitments;
- data ownership, lifecycle, migrations, backfill, rollback, and deletion;
- permissions, tenant isolation, privacy, validation, and abuse cases;
- APIs, integrations, retries, idempotency, partial failure, and recovery;
- UI states, accessibility, empty/loading/error states, and operator workflow;
- post-deploy work: what runs itself (data migration, deploy hook, or
  self-pacing background job) and what, if anything, genuinely needs a human
  decision, and why;
- performance limits, concurrency, observability, rollout, and support;
- alternatives, tradeoffs, dependencies, risks, and explicit open questions.

Probe with concrete scenarios and counterexamples. Distinguish facts verified
in the repository from user decisions and agent assumptions.

## Draft the contract

Draft the spec in the conversation first. Include:

1. Context and problem
2. Goals, non-goals, and success measures
3. Current-state evidence
4. User and operator flows
5. Functional requirements and invariants
6. Data model, API, permission, and integration contracts
7. Failure, recovery, migration, rollback, and observability behavior
8. Testable acceptance criteria
9. Vertical implementation slices with dependencies (normally one PR per
   slice)
10. Simpler designs considered and why they were rejected
11. Risks, decisions, and blocking versus non-blocking open questions

Every acceptance criterion must be observable and every slice independently
testable. Do not prescribe code that contradicts the repository. A spec is an
implementation contract, not an idea dump: resolve user-visible behavior,
scope, data ownership, failure and recovery, migrations/backfill/rollback,
observability, security, and post-deploy work before writing it.

## Adversarial spec gate

Before writing markdown:

1. Have a fresh reviewer, at the repository's review tier for the spec, look
   for contradictions, ambiguity, missing failure
   states, untestable criteria, and scope leakage.
2. Have a fresh repository reviewer verify every material code-path and
   integration claim.
3. Trigger security, domain, data, UX, or reliability review only when the
   spec touches that risk.
4. Revise the draft and present key tradeoffs and all blocking questions.
5. Obtain explicit user approval.

Only then write the approved spec to the repository's spec location (ask if it
has none). Preserve unresolved non-blocking questions explicitly. Do not
implement unless separately asked; hand off the approved spec or one named
vertical slice to `$joe-ship`.
