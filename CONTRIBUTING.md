# Contributing

The most valuable contribution is a reproduction report: run the pipeline on a
paper and say what happened.

## Reproduction reports

Open an issue with the paper, the agent and model you used, the fidelity score
from `review.md`, and — most useful of all — where the pipeline went wrong. The
stages are prompts, so a concrete failure usually turns into a concrete fix:

- A stage produced a vague artifact → the prompt needs a sharper requirement.
- The agent invented a hyperparameter → stage 4's provenance rule needs
  reinforcing at the point where it was violated.
- Files did not fit together → stage 2's shape contracts missed something.
- The review missed an obvious deviation → stage 8 needs a check for that class
  of error.

Please include the artifact that went wrong. A bad `plan.md` says more than a
description of a bad `plan.md`.

## Editing prompts

`prompts/` is the source of truth; the slash commands and Codex prompts are
thin wrappers that point at it. When changing a stage:

- Keep the **Reads** and **Writes** headers accurate — resuming depends on them.
- Say why a rule exists, not just what it is. Agents follow rules they
  understand and route around rules they do not.
- Prefer a concrete example over an abstract instruction. Most of these prompts
  work because they show what a good artifact looks like.
- Do not contradict `prompts/shared/rules.md`. If a stage needs an exception,
  the contract is what should change.
- Test on at least one real paper before opening the pull request, and say
  which one and in which agent.

## Adding support for another agent

Setup instructions in `docs/agents.md` plus, if the agent has a custom prompt
format, a small wrapper that points at `prompts/`. Do not duplicate stage
content into a new format — duplicated prompts drift apart within two commits.

## Scope

This stays a prompt toolkit. No orchestration layer, no Python package, no
service. If a change would require users to install something before their
agent can run the pipeline, it belongs in a different project.
