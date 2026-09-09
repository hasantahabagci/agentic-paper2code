---
description: Review the implementation against the paper and fix what is wrong
---

Run stage 08 (review) of the agentic-paper2code pipeline.

1. Resolve the toolkit root: the first of `${CLAUDE_PLUGIN_ROOT}`,
   `.p2c/toolkit`, the repository root, or `~/.paper2code` that contains a
   `prompts/` directory.
2. Read `prompts/shared/rules.md` — the reproduction contract. It overrides
   anything in the stage prompt that contradicts it.
3. Read `prompts/08-review.md` in full and execute it.
4. Read the current `.p2c/<slug>/STATE.md` first if one exists, and update it
   when the stage finishes, including the **Next action** line.

Requires stage 7. If you have subagents, run the review in a fresh one with no memory of having written the code — self-review of your own output is materially weaker.

Report what you produced, and call out anything the paper leaves ambiguous
rather than resolving it silently.
