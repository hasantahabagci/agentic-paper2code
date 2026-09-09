# Stage 8 — Review

**Goal:** check the implementation against the paper, adversarially, and fix
what is wrong.

**Reads:** `paper/paper.md`, `plan.md`, `config.yaml`, the output repository.
**Writes:** `review.md`, fixes in the repository.

*The rubric below is adapted from the model-based evaluation used in Paper2Code
(Seo et al., ICLR 2026); see NOTICE.*

---

## Review as an adversary

You are looking for places where the code and the paper disagree. Assume they
do. The failure mode of self-review is confirming your own earlier reasoning,
so work from the paper toward the code, never the other way round:

- Take each equation in the paper, find the lines implementing it, and check
  them term by term. Signs, transposes, the order of normalization and
  residual, whether a sum is over the right axis.
- Take each hyperparameter in the paper and grep for its value in the config.
- Take each algorithm's control flow and compare it to the loop that implements
  it, line by line.
- Check what is missing entirely. Missing components do not raise errors, which
  is why they survive every earlier stage.

If your agent supports subagents, run the review as a fresh one with no history
of having written the code. Reviewing code you just wrote is materially weaker.

## Severity

**High** — the paper's core contribution is missing or wrong. The main
algorithm, the loss function, the central architectural mechanism, an
experimental component the claims depend on. If a reader would say "this does
not implement the paper", it is high.

**Medium** — training logic, data preprocessing, or a core piece that
substantially changes results without breaking the system. Wrong loop
structure, wrong augmentation, missing normalization, an off-by-one in a
schedule.

**Low** — deviations that shift results but can be worked around: a different
seed, a different initializer, a metric implementation detail, batching
variation, logging, error handling, or extras not specified by the paper.

Evaluation-code errors are Low unless they touch the core method.

## Score

1 — core concepts not implemented; major logical errors or missing components.
2 — attempts the method but with significant mistakes or omissions.
3 — some core components right, with notable logical errors.
4 — key components and methodology correct, minor inaccuracies only.
5 — all key components, methodology and algorithms implemented without logical
    errors.

## Write `review.md`

```markdown
# Fidelity review

**Score: 3/5**

## Critiques

### High — `model/transformer.py:PositionalEncoding`
Uses learned positional embeddings; the paper (§3.5) specifies fixed
sinusoidal encodings and explicitly reports that the learned variant was
tried and gave nearly identical results but was not the default. The
implemented model is therefore not the reported one.
Fix: replace with `sin(pos/10000^(2i/d))` / `cos(...)` per Eq. 5-6.

### Medium — `train.py:lr_schedule`
Warmup implements a linear ramp; §5.3 Eq. 3 specifies
`d_model^-0.5 · min(step^-0.5, step · warmup^-1.5)`, which decays as
step^-0.5 after warmup rather than staying constant.

### Low — `evaluate.py:bleu`
Uses `sacrebleu` defaults; the paper used multi-bleu.perl on tokenized
output. Scores will differ by roughly a point and are not directly
comparable to Table 2.

## Verified correct
Multi-head attention (§3.2.2), label smoothing (§5.4), the encoder/decoder
stack shape (§3.1), Adam parameters (§5.3).

## Coverage
Equations implemented: 5 of 6. Eq. 4 (positional encoding) — see High above.
Hyperparameters matching the paper: 14 of 17; 3 UNSPECIFIED, listed in
open-questions.md.
```

The "Verified correct" and "Coverage" sections matter as much as the critiques.
A review with no positive findings usually means the reviewer skimmed.

## Then fix

Fix every High and Medium finding. For each fix: make the change, re-run the
stage 7 checks, and append the outcome to `review.md`. Leave Low findings
documented rather than fixed unless they are cheap, and never fix a finding by
weakening a test.

Re-score after fixing and record both scores.

---

Update `STATE.md` and report the before and after scores, the findings you
fixed, and the findings you deliberately left.
