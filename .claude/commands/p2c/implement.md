---
description: Write the repository one file at a time in build order
---

Run stage 06 (implement) of the agentic-paper2code pipeline.

1. Resolve the toolkit root: the first of `${CLAUDE_PLUGIN_ROOT}`,
   `.p2c/toolkit`, the repository root, or `~/.paper2code` that contains a
   `prompts/` directory.
2. Read `prompts/shared/rules.md` — the reproduction contract. It overrides
   anything in the stage prompt that contradicts it.
3. Read `prompts/06-implement.md` in full and execute it.
4. Read the current `.p2c/<slug>/STATE.md` first if one exists, and update it
   when the stage finishes, including the **Next action** line.

Requires stage 5. Strictly sequential — never parallelise this stage. Check each file (compile, import, its test) before starting the next.

Report what you produced, and call out anything the paper leaves ambiguous
rather than resolving it silently.
