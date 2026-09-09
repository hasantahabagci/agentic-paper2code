---
name: paper2code
description: Reproduce a research paper as a working code repository. Use whenever the user wants a paper implemented, reproduced, or turned into code - "implement this arXiv paper", "reproduce this method", "build the model from this PDF", "port this paper to PyTorch". Runs a ten-stage pipeline (ingest, plan, design, tasks, config, analyze, implement, verify, review, package) that produces annotated artifacts, a repository that actually runs, and an honest record of what was and was not verified.
---

# Reproducing a paper as code

This skill runs the agentic-paper2code pipeline. It exists because the usual
approach — handing a PDF to a model and asking for an implementation — produces
code that looks right, has never run, and silently invents the hyperparameters
the paper did not state.

## First, read the contract

Resolve the toolkit root: the first of `${CLAUDE_PLUGIN_ROOT}`, `.p2c/toolkit`,
the repository root, or `~/.paper2code` that contains a `prompts/` directory.

Read `prompts/shared/rules.md` before anything else. Four rules matter most:

1. **Fidelity beats cleverness.** Implement the paper as written. Objections go
   in `notes.md`; the code follows the paper.
2. **Never invent a number.** Every hyperparameter is annotated `# paper §4.1`,
   `# external: <source>`, or `# UNSPECIFIED - <why this value>`. An
   unannotated value is a defect.
3. **No stubs.** No `TODO`, no placeholder bodies, no training loop that never
   steps the optimizer.
4. **State lives on disk.** Update `.p2c/<slug>/STATE.md` after every step, so
   the work survives a lost context window.

Then read `prompts/shared/workspace.md` for the directory layout.

## Then run the stages

Read each prompt in full and execute it in order: `00-ingest`, `01-plan`,
`02-design`, `03-tasks`, `04-config`, `05-analyze`, `06-implement`,
`07-verify`, `08-review`, `09-package`, all under `prompts/`.

Two properties of the pipeline are worth protecting:

- **Stage 5 is separate from stage 6 on purpose.** Reasoning about masking
  logic and managing imports at the same time is how subtle errors get in.
  Analyse every file completely before writing any code.
- **Stage 7 is what makes this different from one-shot generation.** You can
  install dependencies, run the smoke config, overfit a single batch, and fix
  what breaks. Code that has never executed is a hypothesis; use the tools.

Parallelise stage 5 with subagents, one per file. Never parallelise stage 6.

## Check in with the user

After stage 1 (are these the right reproduction targets?), after stage 4 (how
much did the paper leave unspecified?), and after stage 7 (does it run, does it
learn?). Between those, keep going.

## Report honestly

The deliverable includes what failed. Report the fidelity score, the open
questions, the reproduction targets you could not run, and the numbers you got
instead — including the disappointing ones. A reproduction that reports 24.1
against the paper's 27.3 is a useful result. One that claims 27.3 without
having run is worthless.
