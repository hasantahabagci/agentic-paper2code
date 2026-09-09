# Stage 9 — Package

**Goal:** leave behind a repository someone else can pick up, run, and trust.

**Reads:** everything in the workspace.
**Writes:** the output repository's documentation and metadata.

---

## The generated repository gets

### `README.md`

Written for a researcher who has read the paper and wants to run this:

- What this implements, with the paper title, authors, venue and link.
- **A statement of what was and was not verified**, taken from `verify.md`.
  Put it near the top, not in a footnote. This is the most important sentence
  in the file: readers need to know whether they are looking at a validated
  reproduction or a plausible one.
- Install and run, copy-pasteable, starting with the smoke command.
- Repository layout: one line per file.
- Configuration: the keys that matter and where the values came from.
- Results: your numbers next to the paper's numbers, in a table, with the
  hardware and the run length. Empty cells where you did not run something.
- Known deviations from the paper, from `review.md` and `open-questions.md`.
- Citation of the original paper in BibTeX.
- License, and a note that this is an independent reproduction — not the
  authors' code, and not endorsed by them.

### `REPRODUCTION.md`

The claim-to-command map, so a reader can check any number themselves:

```markdown
| Paper claim | Where | Command | Result |
|---|---|---|---|
| Base model, 27.3 BLEU | Table 2 | `python main.py train --config config.yaml` then `python main.py eval` | not run (12h × 8 GPU) |
| Loss follows the §5.3 schedule | §5.3 | `python main.py train --config configs/smoke.yaml --steps 500` | confirmed, see verify.md |
```

### Metadata

- `requirements.txt` with the versions that actually installed and ran.
- `.gitignore` for the ecosystem, plus checkpoints, datasets and run outputs.
- A `LICENSE` if the user wants one — ask rather than assuming, and never
  assume the paper's license carries over to your independent implementation.
- `configs/` containing both the paper config and the smoke config.

### Copy the provenance in

Copy `open-questions.md` and `review.md` into the repository as
`docs/open-questions.md` and `docs/fidelity-review.md`. They are the honest
record of what this reproduction knows and does not know, and they are more
useful inside the repository than in a workspace directory the user may delete.

## Final pass

- `git init` and an initial commit, if the user wants version control.
- Run the smoke command one last time from a clean checkout, in a fresh
  virtual environment. It is common for the last few fixes to have depended on
  something that is not committed.
- Delete dead code, unused imports and abandoned experiments.

---

Update `STATE.md` to mark the reproduction complete, and give the user a final
summary: what was built, what was verified, what remains open, and the exact
command to run it.
