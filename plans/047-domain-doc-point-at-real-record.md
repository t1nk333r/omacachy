# Plan 047: Make `docs/agents/domain.md` describe this repository

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW (documentation only)
- **Depends on**: none (coordinate with 049, which restates the layout)
- **Category**: docs
- **Planned at**: 2026-09-15, from the two-axis review of `main...omacachy`
- **Executed**: 2026-09-15, in the same commit as this file. Took option (a).

## Why this matters

`docs/agents/domain.md` is the upstream seed template, committed unedited. It
documents `CONTEXT.md`, `docs/adr/0001-event-sourced-orders.md`, `src/ordering/`
and `src/billing/`. None of those exist. This repo has no `src/` directory at
all; it has `bin/`, `share/` and `tests/`.

The consequence is not cosmetic. An agent told to read the domain record follows
this file, finds nothing, and never learns that the real record is `handoff.md`
plus `plans/`. This is the same failure plan 030 had to correct once already: a
document asserting something the repository does not support.

## What to do

Choose one:

- **(a) Point it at the real record — recommended.** Rewrite the consumer rules
  to name `handoff.md` as the map and `plans/` as the engineering record, and
  drop the invented ordering/billing examples. Cheapest, and honest about how
  the repo already works.
- **(b) Author a real `CONTEXT.md` and `docs/adr/`.** More work, and it competes
  with `handoff.md` for the same job unless the split between them is defined
  first. Do not start this without deciding what `handoff.md` stops owning.

Whichever is chosen, `AGENTS.md` currently states the `CONTEXT.md` + `docs/adr/`
layout as existing fact and must be corrected to match. That edit is plan 049.

## Verification

- `grep -r 'src/ordering\|src/billing\|event-sourced-orders' docs/` returns
  nothing.
- No path named in `docs/agents/domain.md` is absent from the working tree.
- Under (a), the file names both `handoff.md` and `plans/README.md`.

## Considered and rejected

- **Deleting `docs/agents/` outright**: rejected. The tracker and label
  files are accurate and are already consumed by the review and triage
  skills. Only this file is wrong for the repo.
- **Leaving it as an aspirational template**: rejected. It reads as description,
  not aspiration, and an agent cannot tell the difference.
