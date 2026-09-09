---
description: Fetch a paper and normalize it into the reproduction workspace
---

Run stage 00 (ingest) of the agentic-paper2code pipeline.

1. Resolve the toolkit root: the first of `${CLAUDE_PLUGIN_ROOT}`,
   `.p2c/toolkit`, the repository root, or `~/.paper2code` that contains a
   `prompts/` directory.
2. Read `prompts/shared/rules.md` — the reproduction contract. It overrides
   anything in the stage prompt that contradicts it.
3. Read `prompts/00-ingest.md` in full and execute it.
4. Read the current `.p2c/<slug>/STATE.md` first if one exists, and update it
   when the stage finishes, including the **Next action** line.

The paper to ingest is: $ARGUMENTS — an arXiv ID or URL, a local PDF or LaTeX source, or a paper title. If it is empty, ask the user what to reproduce.

Report what you produced, and call out anything the paper leaves ambiguous
rather than resolving it silently.
