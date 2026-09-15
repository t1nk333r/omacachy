# Plan 049: Bring `AGENTS.md` in line with the repo's document conventions

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW (documentation only)
- **Depends on**: 047 (its outcome decides one line here)
- **Category**: docs
- **Planned at**: 2026-09-15, from the two-axis review that landed as
  commit `0d34e04`
- **Executed**: 2026-09-15, in the same commit as this file.

## Why this matters

`AGENTS.md` opens at `## Agent skills` with no top-level heading. Every sibling
document in the repo (`handoff.md`, `plans/README.md`, and all three files under
`docs/agents/`) opens with an H1 title. It is a small inconsistency in the one
file every agent reads first.

It also carries a factual error inherited from the setup step: it states the
domain layout as "one `CONTEXT.md` at the repo root plus `docs/adr/`", and
neither path exists.

## What to do

- Add an H1 title naming the repository, above the existing `## Agent skills`
  section. Do not disturb the three sub-blocks; the tracker and label summaries
  are correct.
- **Scope note**: this covers the H1 and the factual Domain docs line only. Do
  **not** rewrap `AGENTS.md` or `docs/agents/*.md` to the 80-column prose width
  the rest of the repo uses. Those files are read by agents and by the skills
  that consume them, and the upstream templates ship unwrapped; the divergence
  is deliberate.
- Correct the **Domain docs** line to describe whatever plan 047 settles on. If
  047 takes option (a), this line should name `handoff.md` and `plans/` rather
  than a `CONTEXT.md` that does not exist.
- Consider whether this file should also point at `handoff.md` directly. It is
  the repo's map, and an agent reading only `AGENTS.md` currently never learns
  it exists.

## Verification

- `AGENTS.md` begins with a single H1.
- Every path named in `AGENTS.md` exists in the working tree.
- The Domain docs line and `docs/agents/domain.md` agree with each other.

## Considered and rejected

- **Doing this inside plan 047**: rejected. The domain rewrite is a content
  decision; this is house style plus a one-line correction, and separating them
  keeps 047's rejection record clean.
- **Merging `AGENTS.md` into `handoff.md`**: rejected. The agent-skills block is
  read by tooling that expects it at the repo root under that name.
