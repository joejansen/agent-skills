---
name: systematic-debugging
description: Reproduce a failure, gather evidence, isolate its root cause, implement the smallest justified fix, and verify against the original symptom. Use for bugs, failing tests, flaky behavior, performance regressions, or whenever the cause is not yet demonstrated.
---

# Systematic Debugging

Do not change production code until the failure is reproduced or the missing
evidence is explicitly documented.

## 1. Establish the symptom

Read repository instructions and gather the exact error, environment, inputs,
timeline, expected behavior, and last known good state. Run the smallest
reproduction. Distinguish deterministic failure, flake, and inability to
reproduce. A CI failure that looks flaky is often a bad commit on the default
branch (pull-request CI usually builds the merge ref), so line failing runs up
against recent merges before chasing test isolation.

## 2. Trace evidence

Follow the real data/control path from symptom toward cause. Inspect logs,
state, recent changes, callers, boundaries, and existing tests. Form a short
list of mutually distinguishable hypotheses. For each, name the observation
that would confirm or refute it.

Change one variable at a time. Prefer read-only probes, focused tests, and
temporary instrumentation. Do not stack speculative fixes.

## 3. Prove the cause

A root cause is demonstrated only when evidence explains the symptom and a
focused experiment changes the outcome as predicted. If evidence remains
ambiguous, report what is known and run the next discriminating check.

## 4. Fix minimally

Add the cheapest regression test that exposes the failure where practical,
following the repository's test-cost policy. Implement the
smallest fix at the correct abstraction boundary; avoid unrelated cleanup.
Verify the regression test fails before or would fail without the fix.

## 5. Verify broadly

Re-run the original reproduction, targeted tests, and the full gate the
repository's review tier requires. Give every concurrent test run its own test
database. Check likely sibling paths and negative cases. For flakes or
performance, use repeated or apples-to-apples measurement rather than one green
run.

Report the symptom, proven root cause, rejected hypotheses, fix, commands and
results, and residual uncertainty.
