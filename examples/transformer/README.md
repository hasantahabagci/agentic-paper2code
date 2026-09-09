# Worked example: Attention Is All You Need

A walkthrough of what the pipeline produces, using [arXiv
1706.03762](https://arxiv.org/abs/1706.03762) as the input.

> The excerpts below are **illustrative**. They show the shape and the level of
> detail each artifact is expected to reach, not the output of a recorded run.
> Run the pipeline yourself to produce the real ones — and treat these as the
> quality bar to hold your agent to.

## Starting it

```
/p2c:run 1706.03762
```

or, in any agent without slash commands:

> Reproduce arXiv 1706.03762 following the pipeline in `AGENTS.md`.

## What appears on disk

```
.p2c/attention-is-all-you-need/
├── STATE.md
├── paper/
│   ├── paper.md            full text, equations preserved as LaTeX
│   └── meta.json
├── plan.md
├── design.md
├── tasks.md
├── config.yaml
├── configs/smoke.yaml
├── analysis/
│   ├── model_attention.py.md
│   ├── model_transformer.py.md
│   ├── data_wmt.py.md
│   ├── train.py.md
│   └── evaluate.py.md
├── open-questions.md
├── notes.md
├── verify.md
└── review.md

transformer_repo/           the implementation
```

## Stage 1 — the reproduction targets

The table that decides what the rest of the work aims at:

| Claim | Paper | Where | How we check it | Feasible |
|---|---|---|---|---|
| Base model, 27.3 BLEU on WMT14 en-de | 27.3 | Table 2 | train base config, eval newstest2014 | No — 12 h on 8× P100 |
| Big model, 28.4 BLEU | 28.4 | Table 2 | same | No — 3.5 days on 8× P100 |
| The §5.3 schedule trains stably | — | §5.3 | 500 steps, loss must decrease monotonically after warmup | Yes |
| Attention cost grows as O(n²) | — | §4 | time a forward pass at n ∈ {64, 128, 256, 512, 1024} | Yes |
| Model can learn a sequence task | — | — | overfit 10 copy-task examples to near-zero loss | Yes |

Being explicit that the headline number is out of reach is the point. The
reproduction then aims at what it can actually establish, and says so.

## Stage 4 — configuration with provenance

```yaml
model:
  d_model: 512            # paper §3.1, Table 3 (base row)
  n_heads: 8              # paper §3.2.2
  n_layers: 6             # paper §3.1
  d_ff: 2048              # paper §3.3
  dropout: 0.1            # paper §5.4
  label_smoothing: 0.1    # paper §5.4, eps_ls

training:
  optimizer: adam         # paper §5.3
  beta1: 0.9              # paper §5.3
  beta2: 0.98             # paper §5.3
  eps: 1.0e-9             # paper §5.3
  warmup_steps: 4000      # paper §5.3
  batch_tokens: 25000     # paper §5.1 ("approximately 25000 source tokens")
  steps: 100000           # paper §5.2 (base: 100k steps, 12 hours)
  grad_clip: null         # UNSPECIFIED - not stated; disabled rather than guessed
  seed: 42                # UNSPECIFIED - not stated; fixed for reproducibility
  init: xavier_uniform    # external: tensor2tensor reference implementation
```

The stage ends with a count — here roughly 17 values from the paper, 2
unspecified, 1 external — and the unspecified ones are carried into
`open-questions.md`.

## Stage 5 — analysis before code

From `analysis/model_attention.py.md`:

```
forward(q, k, v, mask=None) -> Tensor
  q, k, v : [B, T_q, d_model], [B, T_k, d_model], [B, T_k, d_model] float32
  mask    : [B, 1, T_q, T_k] bool, True = attend; None = no masking
  returns : [B, T_q, d_model] float32

  1. project q, k, v          -> [B, T, d_model]
  2. reshape to heads         -> [B, n_heads, T, d_k],  d_k = d_model / n_heads
  3. scores = q @ kᵀ / √d_k   -> [B, n_heads, T_q, T_k]        (Eq. 1, §3.2.1)
  4. mask: scores.masked_fill(~mask, -inf)
     -inf rather than -1e9: a fully masked row then yields NaN, which we want
     to surface rather than silently attend uniformly
  5. softmax(dim=-1), dropout -> [B, n_heads, T_q, T_k]
  6. out = attn @ v           -> [B, n_heads, T_q, d_k]
  7. transpose, reshape, W_o  -> [B, T_q, d_model]
```

Every step carries the shape after it. This is what stage 6 transcribes.

## Stage 7 — the part that separates this from a plausible repo

```
Smoke run: python main.py train --config configs/smoke.yaml   34 s, CPU

Failures and fixes
1. Decoder cross-attention mask built as [B, T, T] instead of [B, 1, T_q, T_k].
   Broadcasting made it run and attend to the wrong positions - no exception.
   Fixed in data/collate.py; added tests/test_masks.py asserting the rank.

Learning check
  single-batch overfit: loss 9.21 -> 0.03 over 200 steps      pass
  500 steps on 5k real pairs: 9.4 -> 4.8, monotone after step 60
```

That first failure is the characteristic bug of paper reproduction: it does not
crash, it does not warn, and it makes the model wrong. It was found by running
the code, which is the entire argument for doing this in an agent.

## Stage 8 — fidelity review

```
Score: 4/5

Medium - train.py:lr_schedule
  Warmup ramps linearly, then holds. §5.3 Eq. 3 specifies
  d_model^-0.5 · min(step^-0.5, step · warmup^-1.5), which decays as
  step^-0.5 after warmup. Fixed; re-ran the 500-step check.

Low - evaluate.py:bleu
  sacrebleu defaults vs the paper's multi-bleu.perl on tokenized output.
  Scores differ by about a point and are not directly comparable to Table 2.
  Documented rather than changed.

Verified correct
  multi-head attention (§3.2.2), scaled dot-product (Eq. 1), sinusoidal
  positional encoding (Eq. 5-6), label smoothing (§5.4), post-norm residual
  ordering (§3.1), Adam parameters (§5.3)

Coverage
  equations implemented 6/6, hyperparameters matching the paper 17/17,
  2 UNSPECIFIED (see open-questions.md)
```

## Stage 9 — what the generated README says

Near the top, before anything else:

> **Verified:** the model trains, overfits a single batch, and follows the
> §5.3 schedule. **Not verified:** the WMT14 en-de results in Table 2 — that
> run needs roughly 12 hours on 8 GPUs and was not performed.

That sentence is the deliverable. It tells the next reader exactly how much
weight the repository can carry.
