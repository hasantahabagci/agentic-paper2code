# Stage 6 — Implement

**Goal:** write the repository, one file at a time, in build order, checking
each file before moving to the next.

**Reads:** `tasks.md`, `design.md`, `config.yaml`, `analysis/*.md`, and every
file already written.
**Writes:** the output repository; updates `tasks.md` checkboxes and `STATE.md`.

---

## The loop

For each unchecked file in `tasks.md`, in order:

1. Read its analysis file. Read the frozen interfaces in `design.md`. Read the
   source of the files it imports from — the actual source, not your memory of
   what you intended to write.
2. Write the file completely.
3. Check it (below).
4. Tick the checkbox in `tasks.md`, update `STATE.md`, move on.

Do not batch. Writing five files and then checking them loses the property that
makes this work: every file is written against code that is known to run.

## Writing rules

- **Complete files.** No `TODO`, no placeholder bodies, no "rest of the
  implementation is analogous". If a function is in the analysis, it is in the
  file, fully.
- **Follow the frozen interface exactly.** Same names, same argument order,
  same return types. If the interface turns out to be wrong, stop, fix
  `design.md`, note it in `notes.md`, and check whether already-written files
  need updating. Do not silently diverge — a file that quietly changes a
  signature breaks the next four files.
- **Follow the analysis.** It has already resolved the hard parts. Re-deriving
  the masking logic while writing imports is how the subtle bugs get in.
- **Config, not constants.** Every tunable value comes from the config dict.
  The only literals in the code are structural (`0`, `1`, `-1`, `2` in a
  reshape).
- **Type hints and docstrings.** Google style, one line of summary, args,
  returns, and the paper reference for anything implementing the method.
- **Cite the paper** at each equation, per rule 3 of the contract.
- **Imports at the top**, standard library then third party then local. No
  imports inside functions except to break a genuine cycle, and if you need
  that, the design is wrong.
- **Fail loudly.** Validate assumptions with `assert` or explicit raises where
  a violation would otherwise produce silently wrong numbers — shape mismatches
  that broadcast, masks of the wrong dtype, a config value out of range.

## Checking each file

After writing, in increasing order of cost:

```bash
python -m py_compile <file>                 # syntax
python -c "import <module>"                 # imports resolve, no cycles
python -m pytest tests/test_<name>.py -q    # if the analysis defined a check
```

Where the analysis section 7 specified a verification, write it as a real test
in `tests/`, not as a comment. A repository with a handful of shape tests is
worth far more than one with none, and they take a minute to write while the
reasoning is in front of you.

If a check fails, fix it before moving on. If the failure reveals that the
analysis or design was wrong, fix those documents too — they are the record of
what the code is supposed to do, and a stale record makes stage 8 useless.

## Files that need extra care

- **The entry point** must actually work: `python main.py --help` runs, and
  every subcommand is reachable.
- **The smoke path** must be wired all the way through. If `configs/smoke.yaml`
  selects synthetic data, the loader must honour it without touching the
  network or the disk cache.
- **Anything on the risky list** from `tasks.md` — re-read the paper passage
  itself before writing, not just the analysis.

## Do not run the full experiment yet

Stage 7 handles execution. Here, the bar is: every file is written, imports
resolve, unit checks pass. Resist the urge to start training as soon as
`train.py` exists.

---

When every box in `tasks.md` is ticked, update `STATE.md` and report: files
written, tests added, any interface changes you had to make and why.
