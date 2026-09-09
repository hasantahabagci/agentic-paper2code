# The reproduction contract

Every stage of this pipeline obeys these rules. When a stage prompt and this
file disagree, this file wins. When you are unsure what to do, re-read rule 1.

## 1. Fidelity beats cleverness

You are reproducing a paper, not designing a system. If the paper uses a
suboptimal choice — an old optimizer, an odd normalization order, a strange
schedule — implement the paper's choice. If you are confident it is a mistake,
write the objection in `notes.md` and implement the paper anyway.

The one exception is a claim that is internally inconsistent (two sections give
different values for the same quantity). Then record both in
`open-questions.md`, pick one, and say why in a code comment.

## 2. Never invent a number

Every hyperparameter, dimension, threshold and dataset size must come from one
of three places, and you must be able to say which:

- **From the paper.** Annotate it: `# paper §4.1, Table 2`.
- **From an explicit external source** you consulted (an official repo, a cited
  prior work). Annotate it: `# from Vaswani et al. 2017, §5.4` and log the
  source in `notes.md`.
- **Unspecified.** Mark it: `# UNSPECIFIED - paper does not state this;
  using <value> because <reason>`. Also add a line to `open-questions.md`.

A number with no provenance is a bug. Silently guessing a learning rate is the
single most common way these reproductions go wrong, because the resulting repo
looks correct and is not.

## 3. Cite as you write

Non-obvious code carries a pointer back to the paper: the section, the equation
number, the algorithm line. A reviewer should be able to check any core
function against the paper without searching for the corresponding passage.

```python
# Scaled dot-product attention, paper §3.2.1, Eq. 1.
scores = (q @ k.transpose(-2, -1)) / math.sqrt(self.d_k)
```

## 4. No stubs, no placeholders, no fake work

Forbidden in generated code: `TODO`, `pass  # implement later`, `raise
NotImplementedError` in a path the program actually reaches, hardcoded return
values that pretend to be computed, training loops that do not step the
optimizer, metric functions that return a constant.

If you cannot implement something, do not fake it. Stop, write the blocker in
`open-questions.md`, and say so in your report to the user.

## 5. Config-driven, seeded, reproducible

No magic numbers in code — everything tunable lives in `config.yaml`. Seed
Python, NumPy and the framework RNG from a config key. Log the resolved config
at the start of every run so a result can be traced to the settings that
produced it.

## 6. Every entry point runs small

Before it runs the paper's real experiment, every entry point must run a smoke
path: a tiny model, a handful of synthetic or truncated samples, one or two
steps, CPU-only, finished in under a minute. This is what makes the
implementation verifiable without a GPU cluster, and it is not optional.

Ship `configs/smoke.yaml` alongside the real config.

## 7. Exhaust the paper before you search

The paper is the specification. Read the whole relevant section — including
appendices, figure captions and table footnotes — before you look anything up.
Papers hide learning rates in captions surprisingly often.

When you do go outside the paper, record what you used and why in `notes.md`.
If the authors released code and the user has not forbidden it, reading it is
allowed and useful — but say that you did, because it changes what the
reproduction demonstrates.

## 8. Stay inside the workspace

Reproduction artifacts go under `.p2c/<slug>/`. Generated code goes in the
output repository directory. Do not modify anything else in the user's project,
do not install packages globally, and prefer a virtual environment.

## 9. Write state to disk, not to memory

Long reproductions outlive a single context window. After every meaningful
step, update `STATE.md`. Any agent — including a fresh one with no history —
must be able to read `STATE.md` and continue exactly where the last one stopped.

Do not hold plans in your head. Write them down.

## 10. Surface unknowns instead of resolving them silently

`open-questions.md` is a deliverable, not a scratchpad. An honest reproduction
that lists twelve ambiguities is far more useful than a confident one that
buries them. Every entry gets: what is ambiguous, where in the paper, what you
assumed, and what would change if the assumption is wrong.
