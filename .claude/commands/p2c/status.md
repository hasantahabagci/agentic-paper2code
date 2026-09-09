---
description: Show progress of the current paper reproduction
---

Report the state of the reproductions in this project.

1. List the workspaces under `.p2c/` (each subdirectory is one paper).
2. For each, read `STATE.md` and show: the paper title, the stage table, the
   next action, and any open blockers.
3. Cross-check the state file against reality rather than trusting it:
   - Does every artifact a `done` stage claims actually exist?
   - Does `tasks.md` show more or fewer files ticked than `STATE.md` says?
   - Does the output repository contain the files stage 6 claims to have
     written?
4. Report discrepancies and correct `STATE.md` to match what is on disk.

Then summarize how many open questions are recorded in `open-questions.md` and,
if the review has run, the fidelity score from `review.md`.

Do not start or continue any stage. This command only reports.
