# Workspace layout and state

## Directories

All intermediate artifacts live under `.p2c/<slug>/`, where `<slug>` is a short
kebab-case identifier for the paper (`attention-is-all-you-need`, `mamba`,
`dpo`). Generated code lives outside that directory, so the reproduction is a
normal repository you can run, test and publish.

```
.p2c/
└── <slug>/
    ├── STATE.md              # progress and resume point
    ├── paper/
    │   ├── paper.md          # normalized full text, equations preserved
    │   ├── paper.pdf         # or paper.tex / source tree, when available
    │   └── meta.json         # title, authors, venue, identifier, sections
    ├── plan.md               # stage 1: reproduction plan
    ├── design.md             # stage 2: architecture
    ├── tasks.md              # stage 3: dependency-ordered task list
    ├── config.yaml           # stage 4: hyperparameters with provenance
    ├── analysis/
    │   └── <file>.md         # stage 5: one logic analysis per source file
    ├── open-questions.md     # ambiguities, assumptions, blockers
    ├── notes.md              # external sources consulted, decisions, deviations
    ├── verify.md             # stage 7: run log, failures, fixes
    └── review.md             # stage 8: fidelity review and score

<slug>_repo/                  # the generated implementation (configurable)
```

## STATE.md

`STATE.md` is the single source of truth for progress. Rewrite it after every
stage and after every file you implement. Keep it short enough to read at a
glance.

```markdown
# State: <paper title>

- **Slug**: attention-is-all-you-need
- **Paper**: .p2c/attention-is-all-you-need/paper/paper.md
- **Output repo**: transformer_repo/
- **Updated**: 2026-02-14

| # | Stage     | Status      | Artifact                    |
|---|-----------|-------------|-----------------------------|
| 0 | Ingest    | done        | paper/paper.md              |
| 1 | Plan      | done        | plan.md                     |
| 2 | Design    | done        | design.md                   |
| 3 | Tasks     | done        | tasks.md                    |
| 4 | Config    | done        | config.yaml                 |
| 5 | Analyze   | in progress | analysis/ (4 of 7 files)    |
| 6 | Implement | not started | -                           |
| 7 | Verify    | not started | -                           |
| 8 | Review    | not started | -                           |
| 9 | Package   | not started | -                           |

## Next action
Write `analysis/trainer.md`, then `analysis/evaluate.md`, then `analysis/main.md`.

## Open blockers
- Dataset WMT14 en-de is 4.5 GB; smoke path uses 200 synthetic pairs instead.
```

Status values: `not started`, `in progress`, `done`, `blocked`, `skipped`.

## Resuming

To resume a reproduction: read `STATE.md`, then read the artifacts of every
completed stage, then execute the stage named under **Next action**. Do not
redo completed stages. If an artifact contradicts `STATE.md`, trust the
artifact and correct the state file.
