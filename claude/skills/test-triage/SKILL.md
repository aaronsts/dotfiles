---
name: test-triage
description: Triage the tests in a diff. Ranks each added, changed or deleted test as critical, necessary, nice to have or redundant by the harm its regression would cause. Use when deciding which tests on a branch to keep or drop.
argument-hint: "[base-ref]"
---

# Test triage

Rank each test in a diff by its **blast radius**: the worst harm that ships if the code it guards regresses and this test is gone. The report shows which tests carry the change and which are only maintenance cost. Report only; the test files stay as they are.

## 1. Resolve the diff

- The base is the argument, or `main` when none is given. Diff the working tree against the merge base so uncommitted work counts: `git diff $(git merge-base <base> HEAD)`.
- Add untracked files from `git ls-files --others --exclude-standard`. New test files are often never staged.

## 2. Inventory the tests

List every test case (`it`, `test`, Playwright `test`) the diff adds, changes or deletes, with file and line. A case counts as changed when its body changes or when setup it depends on changes (`beforeEach`, fixtures, shared test helpers).

Done when every added, changed and deleted case in the diff is on the list.

## 3. Name the critical domains

Read enough of the repo (`AGENTS.md` or `CLAUDE.md`, then the code itself) to name where:

- user data is written, migrated, synced, backed up or deleted;
- money moves, or paid access is granted, kept or revoked;
- identity and ownership are checked.

A test can be critical only when it guards code in one of these domains.

## 4. Rank each test

Read the code under test, not only the test: follow the imports into the production code and ask what ships broken if this test were deleted. Judge the assertion, not the title or the file: a test in `billing.test.ts` that only checks a button label is redundant.

| Tier | The regression it catches |
| --- | --- |
| **Critical** | Loses or corrupts user data, loses revenue (wrong charges, paid features for free, paying users locked out), or exposes one user's data to another. Hard to undo once shipped. |
| **Necessary** | A real behavior bug a user would hit: state transitions, validation, branching, calculations, error handling, wiring between modules. Visible, and fixed by the next deploy. |
| **Nice to have** | Real logic with a minor or unlikely failure: a trivial helper, a rare edge case, a path a stronger test mostly covers, or an implementation detail (a mock's call count) that breaks on refactor without any behavior change. |
| **Redundant** | Only UI copy, static markup, layout, class names or "it renders" is asserted; or another test covers the same behavior and branch exactly. |

- Finding an element by its text is fine. A test is redundant when the text itself is the point.
- A test whose mocks replace the logic it names is **hollow**: it exercises only the mocks. Rank it by what really runs and flag it.
- Between two tiers, pick the higher one and name the doubt. Dropping a needed test costs more than keeping a spare one.
- Rank deleted tests too, so a dropped critical test stands out.

Done when every case in the inventory has a tier and a one-line reason.

## 5. Report

Omit empty sections. Each reason names the regression in plain words, not the test's mechanics.

```markdown
## Test triage: <branch> vs <base>, <n> tests

### Critical (<n>)
- `path/to/file.test.ts:42` <test name>: <the regression it catches>

### Necessary (<n>)
- ...

### Nice to have (<n>)
- ...

### Redundant (<n>)
- `path:line` <test name>: <copy only | static markup | duplicates `other/file.test.ts:17`>

### Deleted (<n>)
- `path:line` <test name>, was <tier>: <what is no longer guarded>
```
