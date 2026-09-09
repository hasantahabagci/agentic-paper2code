# Stage 1 — Plan

**Goal:** turn the paper into a reproduction plan detailed enough that someone
who has not read the paper could implement it from your plan alone.

**Reads:** `paper/paper.md`, `paper/meta.json`.
**Writes:** `plan.md`, appends to `open-questions.md`.

---

Read the entire paper before writing anything. Not the abstract and the method
section — the whole thing, appendices included. Nearly every reproduction
failure traces back to a detail in a table footnote that nobody read.

Write `plan.md` with exactly these sections.

## 1. What the paper claims

Three to five sentences: the problem, the proposed method, and the specific
empirical claims. Then list the claims as testable statements, because these
become the reproduction targets in section 7.

## 2. Method decomposition

Break the method into components in the order they must be implemented. For
each component:

- What it computes, in one sentence.
- The governing equations, transcribed as LaTeX with their numbers from the
  paper (`Eq. 4, §3.2`).
- Input and output tensor shapes, with symbolic dimensions (`[B, T, d_model]`).
- Which paper section describes it.
- Anything the paper leaves implicit (initialization, epsilon values, whether
  a norm is pre- or post-residual, the base of a logarithm).

Transcribe the equations even when they seem obvious. The transcription is
where you discover the paper's notation is ambiguous, and it is much cheaper to
discover that now.

## 3. Algorithms

Every numbered algorithm in the paper, rewritten as language-agnostic
pseudocode with explicit loop bounds and update rules. If the paper describes a
procedure in prose without an algorithm box, write the pseudocode anyway.

## 4. Data

- Datasets, exact versions and splits, and where to obtain them.
- Size on disk and whether that is practical here.
- Preprocessing: tokenization, normalization, augmentation, filtering — with
  the parameters and the section they come from.
- **A smoke surrogate**: a tiny synthetic or truncated dataset with the same
  shape and dtype contract as the real one, so the pipeline can run end to end
  without downloading anything. Specify how to generate it.

## 5. Experimental setup

A table of every hyperparameter with its provenance:

| Parameter | Value | Source |
|---|---|---|
| optimizer | Adam, β₁=0.9, β₂=0.98, ε=1e-9 | §5.3 |
| warmup steps | 4000 | §5.3 |
| dropout | 0.1 | §5.4, Table 3 base row |
| gradient clipping | UNSPECIFIED — assume none | not stated |

Follow rule 2 of the contract: every row has a source, and `UNSPECIFIED` is a
legitimate, expected entry. Also record the hardware and wall-clock the authors
used, so the gap between their experiment and yours is explicit.

## 6. Evaluation

Each metric with its exact definition — not the name, the formula. "BLEU" is
not a specification; "BLEU-4 with the multi-bleu.perl tokenization, computed on
the detokenized output" is. State which table or figure of the paper each
metric belongs to, and any averaging or checkpoint-selection protocol.

## 7. Reproduction targets

The contract for "did this work":

| Claim | Paper's number | Where | How we check it | Feasible here |
|---|---|---|---|---|
| Base model reaches 27.3 BLEU on WMT14 en-de | 27.3 | Table 2 | Train base config, eval newstest2014 | No — 12h on 8 GPUs; verify loss curve instead |
| Attention is O(n²) in sequence length | — | §4 | Time forward pass at n ∈ {64,…,1024} | Yes |

Be honest in the last column. Most papers cannot be fully reproduced on the
hardware at hand, and a plan that pretends otherwise produces a repo that has
never actually run. For every infeasible target, name the reduced check that
does run.

## 8. Risks and unknowns

What is most likely to go wrong, and what the paper does not tell you. Copy
each unknown into `open-questions.md` with the assumption you intend to make.

## 9. Scope

State plainly what this reproduction will and will not include. Ablations,
baselines from prior work, and secondary experiments are usually out of scope —
say so rather than leaving it implied.

---

Update `STATE.md` and report: the component count, the reproduction targets and
their feasibility, and the three unknowns most likely to bite.
