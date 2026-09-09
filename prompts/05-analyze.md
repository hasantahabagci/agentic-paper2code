# Stage 5 — Analyze

**Goal:** for each file in the build order, work out exactly what its code must
do — before writing any of it.

**Reads:** `paper/paper.md`, `plan.md`, `design.md`, `tasks.md`, `config.yaml`.
**Writes:** `analysis/<file>.md`, one per source file.

---

Analysis is separated from implementation on purpose. Reasoning about masking
logic while also managing imports and syntax is how subtle errors get in. Here
you only reason; stage 6 only transcribes.

## Working through the list

Take the files in build order. Skip `config.yaml` — stage 4 wrote it.

Files are independent at this stage, since each one is analysed against the
frozen interfaces rather than against the others' code. If your agent supports
subagents, analysing several in parallel is safe and much faster. Give each
subagent the paper, the design, the config and one file's brief.

## Write `analysis/<file>.md`

Name it after the file with slashes replaced by underscores
(`model/attention.py` → `analysis/model_attention.py.md`).

### 1. Responsibility

One paragraph: what this file owns, and explicitly what it does not.

### 2. Paper mapping

Which sections, equations and algorithm lines this file implements. Quote the
equations. If the file implements no part of the paper directly (a data loader,
a CLI), say what it enables instead.

### 3. Public surface

Every class and function, with the exact signature from the frozen design,
default values from `config.yaml`, and the shape contract:

```
class MultiHeadAttention(nn.Module)

  __init__(self, d_model: int, n_heads: int, dropout: float = 0.1)
    Asserts d_model % n_heads == 0. Creates four Linear(d_model, d_model)
    projections (q, k, v, out) — paper §3.2.2 uses separate projections
    per head, mathematically equivalent to one wide projection reshaped.

  forward(self, q, k, v, mask=None) -> Tensor
    q, k, v : [B, T_q, d_model], [B, T_k, d_model], [B, T_k, d_model], float32
    mask    : [B, 1, T_q, T_k] bool, True = attend; None = no masking
    returns : [B, T_q, d_model] float32
```

### 4. Algorithm walkthrough

The body of each non-trivial function as numbered steps, with the tensor shape
after every step. This is where errors are found:

```
forward:
  1. project: q → [B, T, d_model] via W_q
  2. reshape to heads: [B, T, n_heads, d_k] → transpose → [B, n_heads, T, d_k]
  3. scores = q @ k^T / sqrt(d_k)          → [B, n_heads, T_q, T_k]   (Eq. 1)
  4. if mask is not None: scores.masked_fill_(~mask, -inf)
     note: -inf not -1e9; float16 would overflow -1e9 to -inf anyway, but
     -inf makes the intent explicit and softmax handles a fully masked row
     as NaN, which we want to surface rather than hide
  5. attn = softmax(scores, dim=-1); dropout(attn)   → [B, n_heads, T_q, T_k]
  6. out = attn @ v                        → [B, n_heads, T_q, d_k]
  7. transpose, reshape → [B, T_q, d_model]; project via W_o
```

### 5. Edge cases and failure modes

Empty batches, sequences shorter than the window, padding interacting with
causal masks, division by zero, numerical range in reduced precision, the
first and last step of a schedule. Say what the code should do in each.

### 6. Config keys used

The exact keys read, and what happens if one is missing.

### 7. Verification

The concrete check that this file is correct in isolation — a shape assertion,
a known-value test, an invariant (attention rows sum to 1; a causal mask makes
position t independent of t+1). Stage 6 turns these into real tests.

### 8. Uncertainties

Anything the paper leaves open that affects this file, with the decision you
are making. Copy each into `open-questions.md`.

---

After each file, update `STATE.md` with the count analysed. Report which files
turned out to be underspecified by the paper.
