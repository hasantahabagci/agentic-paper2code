# agentic-paper2code

A pipeline for reproducing a research paper as a working code repository. It is
written for coding agents: there is no orchestration code, no API keys and no
service to run. Every stage is a Markdown instruction file that you, the agent,
read and execute using the tools you already have.

If you are an agent reading this file because it is in the user's project, this
is your operating manual for any request of the form *"reproduce this paper"*,
*"implement this arXiv paper"*, or *"turn this PDF into code"*.

## Finding the toolkit

Stage prompts live in a `prompts/` directory. Resolve its location in this
order and use the first that exists:

1. `${CLAUDE_PLUGIN_ROOT}/prompts/` — installed as a Claude Code plugin.
2. `.p2c/toolkit/prompts/` — installed into this project by `install.sh`.
3. `prompts/` at the repository root — you are working inside this repository.
4. `~/.paper2code/prompts/` — installed globally.

Everything below refers to files under that directory.

## Before anything else

Read `prompts/shared/rules.md` — the reproduction contract — and
`prompts/shared/workspace.md`. The contract governs every stage and overrides
any stage instruction it contradicts. The most important rules:

- Implement the paper as written, not as you would improve it.
- Never invent a number. Every value is annotated with where it came from, or
  explicitly marked `UNSPECIFIED`.
- No stubs, no placeholders, no fake computations.
- Write state to `STATE.md` after every step, so the work survives a lost
  context window.

## The stages

Run them in order. Each reads the artifacts of the previous ones and writes its
own into `.p2c/<slug>/`.

| # | Stage | Prompt | Produces |
|---|---|---|---|
| 0 | Ingest | `prompts/00-ingest.md` | `paper/paper.md`, `paper/meta.json` |
| 1 | Plan | `prompts/01-plan.md` | `plan.md` |
| 2 | Design | `prompts/02-design.md` | `design.md` |
| 3 | Tasks | `prompts/03-tasks.md` | `tasks.md` |
| 4 | Config | `prompts/04-config.md` | `config.yaml`, `configs/smoke.yaml` |
| 5 | Analyze | `prompts/05-analyze.md` | `analysis/<file>.md` |
| 6 | Implement | `prompts/06-implement.md` | the repository |
| 7 | Verify | `prompts/07-verify.md` | `verify.md`, a repository that runs |
| 8 | Review | `prompts/08-review.md` | `review.md` |
| 9 | Package | `prompts/09-package.md` | README, `REPRODUCTION.md` |

Do not skip stages, and do not merge them. Stage 5 exists as a separate step
because reasoning about an algorithm while also managing syntax is how subtle
errors get in; stage 7 exists because code that has never run is a hypothesis.

## Running a stage

1. Read `STATE.md` in the workspace, if one exists, to find where you are.
2. Read the stage prompt in full.
3. Read the artifacts the stage declares under **Reads**.
4. Do the work. Write the artifacts it declares under **Writes**.
5. Update `STATE.md`, including the **Next action** line.
6. Report to the user what you found — especially anything the paper leaves
   ambiguous.

Between stages, check in with the user if a decision would change the shape of
the result: which experiment to target, whether a dataset is worth downloading,
whether a full training run is in scope.

## Checkpoints worth pausing at

- **After stage 1 (plan).** The reproduction targets decide what the rest of
  the work is aimed at. Getting them wrong wastes everything downstream.
- **After stage 4 (config).** If a large share of the hyperparameters are
  `UNSPECIFIED`, the user should decide whether to continue, look for the
  authors' code, or narrow the scope.
- **After stage 7 (verify).** The user learns here whether the implementation
  actually runs and learns.

## Parallelism

Stage 5 analyses files independently and parallelises safely — dispatch one
subagent per file if you have them. Stage 6 is strictly sequential: each file
is written against code that already exists and has been checked.

Never parallelise stage 6. Two agents writing interdependent files at once
produce a repository whose parts individually look right and do not fit.

## Resuming

Read `.p2c/<slug>/STATE.md`, read the artifacts of the completed stages, and
execute the stage named under **Next action**. A fresh agent with no history
should be able to do this. If an artifact contradicts `STATE.md`, trust the
artifact and fix the state file.
