Continue an in-progress paper reproduction driven by agentic-paper2code.

1. Find the workspace under `.p2c/`. If there is more than one and the user did
   not say which, list them and ask.
2. Read `STATE.md`, then read the artifacts of every stage marked `done` — the
   real files, not a summary. The plan, the design's frozen interfaces and the
   config all need to be in context before you can continue safely.
3. Check the state against disk. If an artifact is missing or contradicts
   `STATE.md`, trust the files and fix the state file.
4. Read `prompts/shared/rules.md`, then the prompt for the stage named under
   **Next action**, and execute it.
5. Continue through the remaining stages, pausing at the check-in points.

Do not redo completed stages. Rerunning stage 6 after stage 7 discards verified
fixes; if you think an earlier stage was done badly, say so and ask first.
