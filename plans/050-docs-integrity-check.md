# Plan 050: A narrow integrity check for the plan record

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW (read-only script; not wired into any gate)
- **Depends on**: 046 (which restored the index this checks)
- **Category**: tooling
- **Planned at**: 2026-09-15, from the second two-axis review (commit `02d9173`)
- **Executed**: 2026-09-15, in the same commit as this file.

## Why this matters

Two reviews in a row found documents asserting things that were not true: nine
executed plans missing from an index that calls itself authoritative, and a
domain doc describing a source tree this repo does not have. Nothing in the repo
would have caught either.

The argument that actually justifies tooling, rather than just running the
review skill again, is narrower: **plan-record edits are now delegated to fast
models.** The 037-049 index rows were written by `opencode-go/deepseek-v4.1-flash`
and cited nine commit hashes. Every one was verified by hand. A plausible but
invented hash is exactly the failure mode a fast model produces, and hand
verification will not always be that careful.

## What changed

`bin/check-docs.sh`, read-only, two assertions:

1. **Plan files and index rows agree, both directions.** Every
   `plans/NNN-*.md` has exactly one `| NNN |` row, and every row has a file.
   This is the plan-046 defect.
2. **Every cited commit hash resolves**, unless listed in
   `plans/.known-external-refs` with a reason. This is the delegation defect.

The allowlist exists because the record legitimately cites commits that are not
in this repo: upstream pins (a-la-carchy `f6a02bf`, Omarchy `3c88548`) and two
v3-era stamps (`f609f6c`, `baeffd9`) that became unreachable when the v3 line was
dropped on 2026-09-12 and are not in the legacy bundle either. Those cannot be
repointed, so they are recorded rather than silently tolerated. Anything not
listed that fails to resolve is a defect.

## Verification

- Clean tree: `plan files: 49  index rows: 49`, 105 hashes checked, 7 skipped as
  known-external, exit 0.
- Negative tests, each injected then reverted: a plausible but invented commit
  hash, a deleted index row (042), and an orphan row (099) with no file. All
  three failed with the specific message and exit 1.

  (The literal fake hash is deliberately not written here: on first run the
  check flagged this very file for citing it, which is the check working.)

## Considered and rejected

- **Wiring it into `tests/run.sh`**: rejected. That suite tests installer
  behaviour against the fixture matrix; a documentation failure blocking a real
  run is the wrong trade. Run this when touching the plans, especially after
  delegating.
- **Asserting field counts, status prefixes, blank lines, prose width**:
  rejected. Those are review questions, not test questions, and encoding taste
  invites arguing with your own tooling. The two checks kept are objective.
- **Asserting that every path named in the docs exists**: rejected, reluctantly.
  It would have caught the domain-doc defect, but it needs to understand
  explicit negative statements ("there is no `src/` directory") and would flag
  ordinary prose. Worth revisiting if that class of defect recurs.
- **Silently ignoring unresolvable hashes**: rejected. That is the whole check.
