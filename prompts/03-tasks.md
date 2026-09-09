# Stage 3 — Tasks

**Goal:** turn the design into an ordered build plan where every file can be
written correctly using only the files written before it.

**Reads:** `plan.md`, `design.md`.
**Writes:** `tasks.md`.

---

## Order by dependency, not by importance

Sort the file list topologically: a file may only import from files earlier in
the order. Leaves first (config, utilities, data structures), the entry point
last. If you find a cycle, the design is wrong — go back and break it before
writing any code.

## Write `tasks.md`

### 1. Build order

A checklist, in implementation order. Stage 6 ticks these off as it goes, so
keep the format stable.

```markdown
- [ ] 1. `config.yaml` — base configuration (stage 4 writes this)
- [ ] 2. `model/attention.py` — depends on: nothing
- [ ] 3. `model/transformer.py` — depends on: model/attention.py
- [ ] 4. `data/synthetic.py` — depends on: nothing
- [ ] 5. `data/wmt.py` — depends on: nothing
- [ ] 6. `train.py` — depends on: model/transformer.py, data/*
- [ ] 7. `evaluate.py` — depends on: model/transformer.py, data/*
- [ ] 8. `main.py` — depends on: train.py, evaluate.py
- [ ] 9. `tests/test_shapes.py` — depends on: model/*
```

### 2. Per-file brief

For each file, a paragraph that a later stage expands into a full logic
analysis. Include:

- Public surface: classes, functions, their signatures from the frozen design.
- Which paper sections and equations this file implements.
- Which config keys it reads.
- What it must not do (responsibilities belonging to other files).
- The check that proves it works — the assertion, shape test or tiny run.

Be specific. "Implements the model" is not a brief. "Implements `Encoder` as N
identical layers of `[MultiHeadAttention → residual+LayerNorm → FFN →
residual+LayerNorm]`, post-norm as in §3.1 Figure 1, N and d_model from config"
is a brief.

### 3. Required packages

`requirements.txt` content, pinned, matching the design's dependency list. Note
any package that needs a non-pip step (CUDA build, system library, dataset
download tool).

### 4. Shared conventions

The decisions every file must follow, so that separately written files agree:

- Tensor layout: batch-first `[B, T, D]` everywhere, no exceptions.
- Device handling: modules never call `.cuda()`; the caller moves the model.
- Config access: a single `load_config()` returns a dict; no module reads YAML.
- Naming: `d_model`, `n_heads`, `n_layers` — the paper's symbols, spelled out.
- Errors: validate config values at load time, not at first use.
- Logging: one `logging` logger per module, no `print` in library code.
- Random state: everything draws from a seeded generator passed in or global,
  seeded once in `main`.

### 5. Risky files

Rank the files by how likely they are to be wrong: the ones implementing the
paper's actual contribution, the ones with ambiguous specifications, the ones
with subtle shape or masking logic. Stage 5 spends its effort here, and stage 8
reviews these first.

---

Update `STATE.md` and report the build order and the risky files.
