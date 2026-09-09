---
description: Continue a paper reproduction from where it stopped
---

Continue an in-progress reproduction.

1. Find the workspace under `.p2c/`. If more than one exists and the user did
   not say which, list them and ask.
2. Read `STATE.md`, then read the artifacts of every stage marked `done` —
   the actual files, not a summary of them. You need the plan, the design, the
   frozen interfaces and the config in context before you can safely continue.
3. Verify the state against disk. If an artifact is missing or contradicts
   `STATE.md`, trust the files and correct the state file before proceeding.
4. Read `prompts/shared/rules.md`, then the prompt for the stage named under
   **Next action**, and execute it.
5. Keep going through the remaining stages as `/p2c:run` describes, including
   its check-in points.

Do not redo completed stages. If you believe a completed stage was done badly,
say so and ask before repeating it — rerunning stage 6 after stage 7 discards
verified fixes.
