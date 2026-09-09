---
description: Reproduce a paper end to end, from source to a running repository
argument-hint: <arxiv id | url | pdf path | paper title>
---

Reproduce the paper the user named, end to end, using the agentic-paper2code
pipeline. The paper is: $ARGUMENTS

If that is empty, ask the user which paper to reproduce before doing anything.

## Setup

Resolve the toolkit root: the first of `${CLAUDE_PLUGIN_ROOT}`, `.p2c/toolkit`,
the repository root, or `~/.paper2code` that contains a `prompts/` directory.

Read these two files completely before starting:

- `prompts/shared/rules.md` — the reproduction contract. It governs every
  stage and overrides any stage instruction that contradicts it.
- `prompts/shared/workspace.md` — where artifacts go and how `STATE.md` works.

If `.p2c/<slug>/STATE.md` already exists for this paper, this is a resume:
read it, read the artifacts of the completed stages, and continue from the
**Next action** line instead of starting over.

## Run the stages in order

Read each prompt in full, execute it, write its artifacts, update `STATE.md`,
then move to the next.

1. `prompts/00-ingest.md`
2. `prompts/01-plan.md`
3. `prompts/02-design.md`
4. `prompts/03-tasks.md`
5. `prompts/04-config.md`
6. `prompts/05-analyze.md` — parallelise across files with subagents
7. `prompts/06-implement.md` — strictly sequential, one file at a time
8. `prompts/07-verify.md`
9. `prompts/08-review.md` — use a fresh subagent as the reviewer if you can
10. `prompts/09-package.md`

Track the ten stages in your todo list so progress stays visible.

## Pause and check in

Stop and ask the user after these stages, then continue once they answer:

- **After stage 1.** Show the reproduction targets from `plan.md` §7 and
  confirm the scope. Everything downstream is aimed at these.
- **After stage 4.** Report how many hyperparameters are `UNSPECIFIED`. If it
  is a large share, the user may want to narrow scope or look for the authors'
  code before you build on guesses.
- **After stage 7.** Report whether it runs and whether it learns.

Do not stop at every stage. Between checkpoints, keep going and summarize
briefly as you pass each one.

## Finish

Report: what was built, what was verified and what was not, the fidelity score
from `review.md`, the open questions that remain, and the exact command to run
the reproduction.
