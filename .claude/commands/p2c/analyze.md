---
description: Write a per-file logic analysis before any code exists
---

Run stage 05 (analyze) of the agentic-paper2code pipeline.

1. Resolve the toolkit root: the first of `${CLAUDE_PLUGIN_ROOT}`,
   `.p2c/toolkit`, the repository root, or `~/.paper2code` that contains a
   `prompts/` directory.
2. Read `prompts/shared/rules.md` — the reproduction contract. It overrides
   anything in the stage prompt that contradicts it.
3. Read `prompts/05-analyze.md` in full and execute it.
4. Read the current `.p2c/<slug>/STATE.md` first if one exists, and update it
   when the stage finishes, including the **Next action** line.

Requires stage 4. Files are independent here: dispatch one subagent per file to analyse them in parallel, giving each the paper, the design, the config and that file's brief from tasks.md.

Report what you produced, and call out anything the paper leaves ambiguous
rather than resolving it silently.
