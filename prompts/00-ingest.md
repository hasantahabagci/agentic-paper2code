# Stage 0 — Ingest

**Goal:** get the paper onto disk as complete, readable text, and open a
workspace for it.

**Reads:** whatever the user gave you.
**Writes:** `.p2c/<slug>/paper/`, `.p2c/<slug>/STATE.md`.

---

## Accept any of these inputs

| Input | What to do |
|---|---|
| arXiv ID or URL (`2504.17192`, `arxiv.org/abs/...`) | Fetch the LaTeX source first: `https://arxiv.org/e-print/<id>` is a gzipped tar of the real source. Fall back to `https://arxiv.org/pdf/<id>`. |
| Local PDF | Use it directly. |
| Local `.tex` file or LaTeX source tree | Use it directly; resolve `\input`/`\include` so the text is complete. |
| OpenReview / ACL Anthology / journal URL | Follow it to the PDF. |
| A paper title only | Search for it, confirm the match with the user before proceeding — reproducing the wrong paper is expensive. |

Prefer LaTeX over PDF whenever both exist. LaTeX keeps equations, table
structure and section numbering intact; PDF extraction mangles all three, and
every later stage depends on citing sections and transcribing equations
correctly.

## Normalize to `paper/paper.md`

Produce one Markdown file containing the paper's full text. Extraction options,
in order of preference — use whichever is available:

1. Your own file reader, if it reads PDFs natively.
2. LaTeX source, de-macroed by hand into Markdown.
3. `pdftotext -layout paper.pdf paper.txt` (poppler-utils).
4. A document converter such as `marker`, `docling`, or `s2orc-doc2json`
   (the last one is what the original Paper2Code pipeline used).

Rules for the normalized text:

- **Keep everything that specifies behaviour.** Method, architecture,
  algorithms, training details, datasets, evaluation protocol, and the
  appendices — appendices routinely hold the hyperparameters.
- **Do not summarize.** This is a cleaning step, not a compression step. A
  summary here silently deletes the details the implementation needs.
- **Keep equations as LaTeX**, inline as `$...$` and display as `$$...$$`.
  Preserve equation numbers; later stages cite them.
- **Keep section numbers** exactly as printed. Provenance annotations
  throughout the pipeline refer to them.
- **Keep tables as Markdown tables**, including footnotes.
- **Keep figure captions**, as an image reference when you extracted the image
  and as `**Figure 3.** <caption>` when you did not. Captions often carry
  hyperparameters, so never drop them.
- **Drop** the bibliography, acknowledgements, author affiliations, ethics and
  reproducibility boilerplate, and page furniture. Keep a citation's key in the
  text (`[23]` or `(Vaswani et al., 2017)`) so references stay traceable.
- **Flag damage.** If a formula, table or algorithm block came out unreadable,
  insert `> [EXTRACTION GAP] Algorithm 1 did not extract; re-read page 4 of the
  PDF before implementing it.` Do not guess at what it said.

## Write `paper/meta.json`

```json
{
  "title": "Attention Is All You Need",
  "authors": ["Ashish Vaswani", "..."],
  "venue": "NeurIPS 2017",
  "identifier": "arXiv:1706.03762",
  "url": "https://arxiv.org/abs/1706.03762",
  "slug": "attention-is-all-you-need",
  "source_format": "latex",
  "has_official_code": false,
  "sections": ["1 Introduction", "2 Background", "3 Model Architecture", "..."]
}
```

Set `has_official_code` by checking the paper for a code link. Do not go
looking for an unofficial reimplementation — knowing whether the authors
released code changes what the reproduction is worth, and stage 1 needs it.

## Finish

1. Create `open-questions.md` and `notes.md` as empty stubs with a heading.
2. Write `STATE.md` with stage 0 `done` and stage 1 as the next action.
3. Report to the user: title, venue, section count, extraction method, and any
   `[EXTRACTION GAP]` markers you left. If the extraction is poor, say so now —
   it is much cheaper to fix here than after implementation.
