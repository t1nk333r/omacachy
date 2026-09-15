# Domain Docs

How the engineering skills should consume this repo's domain record when exploring the codebase.

## Before exploring, read these

- **`handoff.md`** at the repo root: the map. It names the components (`bin/`, `share/`, `tests/`) and their state, the version policy, how validation stands and the release gates. Read it first.
- **`plans/`**: the numbered engineering record. Read **`plans/README.md`** (the status table and discoveries index) second, then the specific `plans/NNN-*.md` for the area you're touching.

If a file you expect is missing, proceed silently. Don't flag its absence; don't suggest creating it upfront.

## File structure

```
/
├── handoff.md            ← the map: components, version policy, release gates
├── plans/
│   ├── README.md         ← the engineering record index
│   └── NNN-*.md          ← one file per plan
├── bin/                  ← entry-point scripts plus bin/lib/ helpers
├── share/                ← profile-paths.conf
├── tests/                ← the fixture matrix (run.sh)
└── docs/agents/          ← these agent docs
```

There is no `src/` directory; the code lives under `bin/`.

## Use the record's vocabulary

When your output names a component, a version, or a validation state (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as `handoff.md` and the plan files define it. Don't drift to synonyms those documents explicitly avoid.

If the concept you need isn't recorded yet, that's a signal: either you're inventing language the project doesn't use (reconsider), or there's a real gap (note it in the relevant plan or in `handoff.md`).

## Flag conflicts with recorded decisions

If your output contradicts a decision in `handoff.md` or an executed plan, surface it explicitly rather than silently overriding:

> _Contradicts plan 030 (docs and version truth), but worth reopening because…_
