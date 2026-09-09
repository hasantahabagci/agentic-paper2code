# Stage 7 — Verify

**Goal:** make the repository actually run, and record what happened.

**Reads:** the output repository, `plan.md` §7 reproduction targets.
**Writes:** `verify.md`, fixes in the repository, appends to `open-questions.md`.

---

This stage is the reason an agent-run pipeline beats a one-shot generator. Code
that has never been executed is a hypothesis. Everything below is about turning
it into a fact.

## 1. Environment

Create an isolated environment and install the pinned dependencies:

```bash
python -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
```

Record the Python version, the versions actually resolved, and the hardware you
are on. If a dependency fails to install, fix `requirements.txt` — a repo that
does not install is not reproducible, whatever its contents.

## 2. Smoke run

```bash
python main.py train --config configs/smoke.yaml
python main.py eval  --config configs/smoke.yaml
```

The bar: end to end, no crash, under a minute, on CPU. Every code path the real
experiment uses should be exercised at least once — model construction, a
forward pass, a backward pass, an optimizer step, a checkpoint save and load,
an evaluation pass, metric computation.

## 3. Debugging discipline

When something fails:

- **Find the root cause before editing.** Read the traceback, inspect the
  actual shapes and values, form a hypothesis, test it. Do not rewrite a file
  because it errored.
- **Smallest possible edit.** A shape bug is fixed by fixing the shape, not by
  regenerating the module.
- **Never delete the check.** Relaxing an assertion, wrapping a failure in
  `try/except`, or lowering a threshold until it passes converts a visible bug
  into an invisible one. If an assertion is wrong, prove it is wrong first.
- **Re-read the paper when the bug is semantic.** A dimension mismatch in
  attention often means the analysis misread the paper, not that the code has
  a typo.
- **Three strikes.** If the same failure survives three genuine fix attempts,
  stop, write it up in `open-questions.md`, and tell the user. Continued
  thrashing produces damage, not progress.
- **Keep the log.** Every failure and fix goes into `verify.md`: what failed,
  the root cause, the change, and how you confirmed it.

## 4. Learning sanity check

Passing a smoke run only proves the plumbing works. Now check that the method
learns:

- Train briefly on a small but real slice — a few hundred steps.
- The loss must decrease. If it is flat, the gradient path is broken somewhere;
  check that the optimizer sees the parameters, that the loss depends on the
  output, and that nothing is detached.
- Overfit a single batch on purpose. A correct model drives training loss on
  ten examples to near zero. If it cannot, the model is wrong, not undertrained.
  This single test catches more implementation bugs than any other.
- Check the shapes and ranges of intermediate tensors once, by hand.

## 5. Reproduction targets

Work through the table in `plan.md` §7. For each target:

- Feasible here: run it, record the number next to the paper's number.
- Not feasible: run the reduced check named in the plan and record that
  instead, stating plainly what was and was not verified.

Report the numbers you got, including the disappointing ones. A reproduction
that reports 24.1 BLEU against the paper's 27.3 is a useful result; one that
claims 27.3 without having run is worthless.

## 6. Write `verify.md`

```markdown
# Verification log

## Environment
Python 3.11.8, torch 2.4.1+cpu, 16-core CPU, no GPU.

## Smoke run
`python main.py train --config configs/smoke.yaml` — passes in 34 s.

## Failures and fixes
1. **Shape mismatch in decoder cross-attention.**
   Cause: mask built as [B, T, T] instead of [B, 1, T_q, T_k]; broadcasting
   silently produced the wrong attention pattern rather than erroring.
   Fix: build the mask in `data/collate.py:mask_for()`. Added
   `tests/test_masks.py` asserting the rank.
2. ...

## Learning check
Single-batch overfit: loss 9.21 → 0.03 in 200 steps. Passes.
500-step run on 5k WMT pairs: loss 9.4 → 4.8, monotone after step 60.

## Reproduction targets
| Claim | Paper | Ours | Notes |
|---|---|---|---|
| Base BLEU, WMT14 en-de | 27.3 | not run | 12h × 8 GPU; out of scope here |
| Loss decreases under the §5.3 schedule | — | confirmed | see above |

## Not verified
Full training, beam search width 4 with length penalty, multi-GPU path.
```

Be exact about the last section. It is what an honest reproduction looks like.

---

Update `STATE.md` and report: does it run, does it learn, what was verified and
what was not.
