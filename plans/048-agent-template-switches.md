# Plan 048: Settle the two unfilled switches in the agent docs

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW (documentation only)
- **Depends on**: none
- **Category**: docs
- **Planned at**: 2026-09-15, from the two-axis review of `main...omacachy`
- **Executed**: 2026-09-15, in the same commit as this file. Kept the table as
  a registry; gated the `gh pr` block rather than deleting it.

## Why this matters

Two of the three files under `docs/agents/` were committed as seed templates
with their configuration switches left in the default position and the
template's own editing instructions still attached. Both are accurate for this
repo, so neither is a defect in behaviour. Both are dead weight that reads as
live instruction, which is the thing these docs exist to avoid.

## What to do

### `docs/agents/triage-labels.md`

The mapping table's two columns are byte-identical (`needs-triage` maps to
`needs-triage`, and so on for all five), and the file still ends with the
template's instruction: "Edit the right-hand column to match whatever vocabulary
you actually use."

The mapping maps nothing, and `AGENTS.md` already states that each label string
equals its name. Either:

- delete the table and keep the one-line statement, or
- keep the table as an explicit registry and delete the editing instruction.

Do not keep both the identity table and the instruction to edit it.

### `docs/agents/issue-tracker.md`

`PRs as a request surface: no.` is the correct setting for this repo. Beneath it
sit roughly twenty lines of `gh pr` procedure that are unreachable while the
flag is off, with nothing marking them as conditional. Either:

- move them under an explicit heading naming the flag state they apply to, or
- cut them, since the flag can be flipped and the template re-consulted.

## Verification

- No file under `docs/agents/` contains an instruction addressed to whoever is
  filling in the template.
- Any procedure that applies only when a flag is set is under a heading that
  says so.
- The five canonical label names still appear; the triage skill reads them.

## Considered and rejected

- **Flipping the PR flag to `yes`**: rejected. This repo does not treat external
  pull requests as feature requests, and turning it on to justify the prose
  would be the tail wagging the dog.
- **Renaming the labels to something repo-specific**: rejected. The canonical
  five are what the triage skill expects, and nothing needs different names.
