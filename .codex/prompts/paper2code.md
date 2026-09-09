Reproduce a research paper as a working code repository, using the
agentic-paper2code pipeline.

The paper is: $ARGUMENTS
If that is empty, ask which paper to reproduce before doing anything else.

## Setup

Find the toolkit: look for a `prompts/` directory in `.p2c/toolkit/`, in the
current repository root, or in `~/.paper2code/`. Use the first one you find.

Read `prompts/shared/rules.md` completely before starting. It is the
reproduction contract and it overrides any stage instruction that contradicts
it. Then read `prompts/shared/workspace.md` for where artifacts go.

If `.p2c/<slug>/STATE.md` already exists for this paper, read it and continue
from its **Next action** line rather than starting over.

## Stages

Read each prompt in full, execute it, write its artifacts, update `STATE.md`,
then move on:

1. `prompts/00-ingest.md` — fetch the paper, normalize it to Markdown
2. `prompts/01-plan.md` — reproduction plan and targets
3. `prompts/02-design.md` — architecture, frozen interfaces, shape contracts
4. `prompts/03-tasks.md` — dependency-ordered build plan
5. `prompts/04-config.md` — hyperparameters, every value annotated
6. `prompts/05-analyze.md` — per-file logic analysis, before any code
7. `prompts/06-implement.md` — one file at a time, checked after each
8. `prompts/07-verify.md` — install, run, debug, overfit a batch
9. `prompts/08-review.md` — adversarial review against the paper, then fix
10. `prompts/09-package.md` — document what was and was not verified

Do not skip or merge stages. Stage 5 is separate from stage 6 because reasoning
about an algorithm while managing syntax is how subtle errors get in. Stage 7
is what makes this worth running in an agent at all: you can execute the code,
so do.

## Check in

Pause for the user after stage 1 (confirm the reproduction targets), after
stage 4 (report how much the paper left unspecified), and after stage 7 (does
it run, does it learn). Keep going between those points.

## Finish

Report what was built, what was verified and what was not, the fidelity score,
the remaining open questions, and the command to run the reproduction.
