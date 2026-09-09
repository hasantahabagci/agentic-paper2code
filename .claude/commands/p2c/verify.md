---
description: Install, run, debug and sanity-check the implementation
---

Run stage 07 (verify) of the agentic-paper2code pipeline.

1. Resolve the toolkit root: the first of `${CLAUDE_PLUGIN_ROOT}`,
   `.p2c/toolkit`, the repository root, or `~/.paper2code` that contains a
   `prompts/` directory.
2. Read `prompts/shared/rules.md` — the reproduction contract. It overrides
   anything in the stage prompt that contradicts it.
3. Read `prompts/07-verify.md` in full and execute it.
4. Read the current `.p2c/<slug>/STATE.md` first if one exists, and update it
   when the stage finishes, including the **Next action** line.

Requires stage 6.

Report what you produced, and call out anything the paper leaves ambiguous
rather than resolving it silently.
