# Plan 046: Restore the missing plan-index rows (037–049)

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW (documentation only; no runtime code is touched)
- **Depends on**: none
- **Category**: docs
- **Planned at**: 2026-09-15, from the two-axis review of `main...omacachy`
- **Executed**: 2026-09-15, in the same commit as this file (rows 037–049
  appended; delegated to `opencode-go/deepseek-v4.1-flash`, verified here).

## Why this matters

`plans/README.md` calls itself the authoritative status index, and `handoff.md`
points at it as the map to the engineering record. Its "Execution order &
status" table stops at plan **036**. Nine executed plan files exist with no
index row at all, so the authoritative index silently under-reports the last
nine pieces of work. Anyone reading it to learn where the project stands gets a
picture that ends at 036.

## What to do

Add one row per missing plan, plus rows for this plan and the three
planned alongside it (047–049, all TODO):

| Missing | File |
|------|------|
| 037 | `037-iso-closure-xdg-user-dirs.md` |
| 038 | `038-debloat-empty-selection.md` |
| 039 | `039-iso-closure-chromium.md` |
| 040 | `040-apply-failures-and-artifacts.md` |
| 041 | `041-limine-cmdline-params.md` |
| 042 | `042-closure-mise-bin.md` |
| 043 | `043-omarchy-base-packages.md` |
| 044 | `044-profile-migration-hardening.md` |
| 045 | `045-pre-install-snapshot.md` |
| 046 | this plan |
| 047 | `047-domain-doc-point-at-real-record.md` |
| 048 | `048-agent-template-switches.md` |
| 049 | `049-agents-md-house-style.md` |

Read Priority / Effort / Depends on / Status from each plan's own `## Status`
block rather than from its commit subject: several of them record verification
evidence and caveats that a subject line does not carry (045, for one, records
which branches were exercised in the lab and which were only mock-verified).

Rows **035** and **036** are currently separated from the table body by blank
lines. Either keep that or normalise it, but decide deliberately rather than
inheriting it.

**Not applicable here**: this repo has no roadmap generator (no
`gen-roadmap.py`, no `docs/Roadmap.md`, no `validate.sh`), so the
status-prefix-ordering rule that governs the *waydots* index does not apply.
Status cells only need to begin with one of the documented values:
`TODO | IN PROGRESS | DONE | BLOCKED | REJECTED`.

## Verification

- Every `plans/NNN-*.md` file has exactly one `^| NNN |` row, and every row has
  a file. The two counts are equal.
- Every row has eight pipe-delimited fields, matching the existing table.
- Every status cell starts with a documented status value.

## Considered and rejected

- **Back-filling from `git log` alone**: rejected. Commit subjects drop the
  verification caveats that several of these plans record in their own status
  blocks.
- **Dropping the index table and generating it**: rejected here as out of scope.
  It is a real option, but it is a tooling change, not a reconciliation, and it
  would need its own plan.
