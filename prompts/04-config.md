# Stage 4 — Config

**Goal:** extract every number the implementation needs into one annotated
configuration file, and make the gaps visible.

**Reads:** `paper/paper.md`, `plan.md`, `design.md`.
**Writes:** `config.yaml`, `configs/smoke.yaml`, appends to `open-questions.md`.

---

This is the stage where reproductions are quietly lost. A generated repository
with an invented learning rate looks exactly like one with the paper's learning
rate, and produces different results forever. So the rule here is absolute:
**every value carries its provenance, in a comment, on its own line.**

## Sweep the paper for numbers

Before writing the file, collect values from all of these places — the last
three are the ones people skip:

- The method and experiments sections.
- Tables of results (the configuration columns, not just the scores).
- **Table footnotes and figure captions.**
- **Appendices**, especially "implementation details" and "training details".
- **Prose asides**: "we use the same setup as [23]" means you now have to look
  at what [23] used, and record that as an external source.

## Provenance annotation

Three legal forms, matching rule 2 of the contract:

```yaml
model:
  d_model: 512          # paper §3.1, Table 3 (base)
  n_heads: 8            # paper §3.2.2
  d_ff: 2048            # paper §3.3
  dropout: 0.1          # paper §5.4

training:
  optimizer: adam       # paper §5.3
  beta1: 0.9            # paper §5.3
  beta2: 0.98           # paper §5.3
  eps: 1.0e-9           # paper §5.3
  warmup_steps: 4000    # paper §5.3
  label_smoothing: 0.1  # paper §5.4
  grad_clip: null       # UNSPECIFIED - not stated; disabled rather than guessed
  batch_tokens: 25000   # paper §5.1 ("approximately 25000 source tokens")
  seed: 42              # UNSPECIFIED - not stated; fixed for reproducibility
  init: xavier_uniform  # external: Vaswani et al. reference implementation
```

- `# paper §X` — stated in the paper. Cite the most specific location.
- `# UNSPECIFIED - <why this value>` — not in the paper. Choose a defensible
  default and say why. Every one of these also gets a line in
  `open-questions.md`.
- `# external: <source>` — taken from somewhere else. Also log it in `notes.md`.

An unannotated value is a defect. If you find yourself about to write one, you
are guessing — mark it `UNSPECIFIED` instead.

## Structure

Group by concern, matching the configuration surface from the design:
`model`, `data`, `training`, `eval`, `runtime`. Keep it flat enough to read;
two levels of nesting is usually enough. Put derived values in code, not in
config — if `d_k = d_model / n_heads`, compute it.

## `configs/smoke.yaml`

The same schema, shrunk until it runs on a CPU in under a minute:

```yaml
# Smoke configuration: verifies the pipeline runs end to end.
# Not a reproduction of the paper's results.
model:
  d_model: 32
  n_heads: 2
  n_layers: 2
data:
  source: synthetic     # data/synthetic.py, no download
  n_samples: 128
  max_len: 16
training:
  max_steps: 5
  batch_size: 8
runtime:
  device: cpu
```

Put the disclaimer comment at the top. Someone will eventually run this and
report that the BLEU score is terrible.

## Unspecified count

End the stage by counting: how many values came from the paper, how many are
`UNSPECIFIED`, how many are external. Report the counts. A paper with 30% of
its configuration unspecified is a legitimate finding about the paper, and the
user should hear it now rather than after training.

---

Copy `config.yaml` into the output repository root, update `STATE.md`, and
report the three unspecified values most likely to affect results.
