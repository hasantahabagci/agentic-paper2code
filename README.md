# agentic-paper2code

Turn a research paper into a code repository that actually runs — using the
coding agent you already have.

No API keys. No orchestration scripts. No Python package to install. The whole
pipeline is a set of Markdown stage prompts that Claude Code, Codex, Cursor,
Gemini CLI or any other file-editing agent reads and executes with its own
tools.

```
/p2c:run 1706.03762
```

Ten stages later you have an implementation, a record of every hyperparameter
and where it came from, a log of what was run, a fidelity review against the
paper, and an honest statement of what was and was not verified.

---

## Why not just ask a model to implement the paper?

You get a repository that looks right. Usually three things are wrong with it:

- **It has never run.** Nothing executed the code, so shape mismatches, broken
  masks and silent broadcasting all survive to the reader.
- **It invented numbers.** The paper did not state the warmup schedule, so the
  model wrote one. Nothing distinguishes a value from Table 3 from a value from
  nowhere — and the second kind never reproduces.
- **It drifted.** The attention module written first and the trainer written
  last disagree about tensor layout, because nothing froze the interface
  between them.

An agent can fix all three, because it can execute code, keep artifacts on disk
and check its own output. That is what this pipeline makes it do.

## Install

**Claude Code, as a plugin:**

```
/plugin marketplace add hasantahabagci/agentic-paper2code
/plugin install agentic-paper2code@hasantahabagci
```

**Any agent, into a project:**

```bash
curl -fsSL https://raw.githubusercontent.com/hasantahabagci/agentic-paper2code/main/install.sh | bash
```

**Or clone and choose:**

```bash
git clone https://github.com/hasantahabagci/agentic-paper2code
cd agentic-paper2code
./install.sh                      # this project
./install.sh --global             # every project on this machine
./install.sh --codex              # also install Codex CLI prompts
./install.sh --project ~/work/x   # somewhere specific
```

## Use

| Agent | How |
|---|---|
| Claude Code | `/p2c:run 1706.03762` |
| Codex CLI | `/paper2code 1706.03762` |
| Cursor, Windsurf, Zed, Gemini CLI, opencode, Copilot | "Reproduce arXiv 1706.03762 following the pipeline in `AGENTS.md`." |

Input can be an arXiv ID or URL, a local PDF, a LaTeX source tree, or a title.
LaTeX is preferred when you have it — equations, tables and section numbers
survive intact, and every later stage cites them.

Other commands: `/p2c:status` shows progress, `/p2c:resume` continues after a
session ends, and each stage has its own command if you want to drive it by
hand.

## The pipeline

| # | Stage | Produces | What it is for |
|---|---|---|---|
| 0 | Ingest | `paper/paper.md` | full text with equations, tables and appendices intact |
| 1 | Plan | `plan.md` | method decomposition, data, and a table of reproduction targets |
| 2 | Design | `design.md` | file list, frozen interfaces, tensor shape contracts |
| 3 | Tasks | `tasks.md` | dependency-ordered build plan, per-file briefs |
| 4 | Config | `config.yaml` | every hyperparameter, annotated with its source |
| 5 | Analyze | `analysis/*.md` | reason through each file before writing any code |
| 6 | Implement | the repository | one file at a time, compiled and tested after each |
| 7 | Verify | `verify.md` | install, run, overfit a batch, debug what breaks |
| 8 | Review | `review.md` | adversarial check against the paper, then fix |
| 9 | Package | README, `REPRODUCTION.md` | state plainly what was and was not verified |

Artifacts land in `.p2c/<slug>/`; the implementation lands in its own directory
as a normal repository you can run and publish.

## The four ideas that make the output trustworthy

**Provenance on every number.** Values in `config.yaml` carry `# paper §5.3`,
`# external: <source>`, or `# UNSPECIFIED - <why this value>`. Guessing is
allowed; guessing silently is not. The config stage ends by counting each kind,
so you learn early if a paper leaves a third of its setup unstated — which is
itself worth knowing before you spend a GPU-week on it.

**Frozen interfaces with shape contracts.** Signatures and tensor shapes are
fixed in stage 2 and every later file is written against them. Files produced
hours apart in different context windows still fit together.

**Analysis before code.** Stage 5 writes out each algorithm step by step with
the tensor shape after every step; stage 6 transcribes that into Python.
Reasoning about masking logic while also managing imports is how the subtle
bugs get in, so the pipeline refuses to do both at once.

**Execution, not assertion.** Stage 7 builds an environment, runs a
one-minute CPU smoke config end to end, and deliberately overfits a single
batch — a correct model drives loss on ten examples to near zero, an incorrect
one cannot. It is the single most effective test in the pipeline, and it is
only possible because an agent can run things.

## Works when the context runs out

Long reproductions outlive a context window. Every stage writes durable
artifacts and updates a small `STATE.md` holding the stage table, the next
action and any blockers. A fresh agent — a new session, or a different agent
entirely — reads it and continues. Nothing is serialized into a vendor's
message format, so you can start in Claude Code and finish in Codex.

## Documentation

- [How it works](docs/how-it-works.md) — why the stages are split the way they are
- [Running it in your agent](docs/agents.md) — setup for each tool
- [Worked example](examples/transformer/README.md) — what the artifacts look like
- [The reproduction contract](prompts/shared/rules.md) — the ten rules every stage obeys
- [AGENTS.md](AGENTS.md) — the operating manual agents read

## Credit

This project is built on the pipeline introduced in **Paper2Code**
([repository](https://github.com/going-doer/Paper2Code),
[paper](https://arxiv.org/abs/2504.17192)) by Minju Seo, Jinheon Baek, Seongyun
Lee and Sung Ju Hwang, ICLR 2026. The planning → analysis → coding decomposition
is theirs, and it works; the stage prompts here are adapted from theirs under
Apache-2.0.

What changed is the execution model. The original runs as a Python program that
calls the OpenAI API stage by stage, accumulating message trajectories in
memory and billing per token. This version removes that layer entirely and
hands the stages to an agent that can already read, write and run code — which
also made it possible to add the stages an API pipeline cannot do: ingestion,
environment setup, smoke runs, debugging, fidelity review and packaging. See
[NOTICE](NOTICE) for the full list of changes.

## Citing

If this toolkit is useful in a publication, cite both — this repository for the
pipeline you ran, and the Paper2Code paper for the method it is built on:

```bibtex
@software{bagci2026agenticpaper2code,
  title  = {agentic-paper2code: Reproducing Research Papers with Coding Agents},
  author = {Bagci, Hasan Taha},
  year   = {2026},
  url    = {https://github.com/hasantahabagci/agentic-paper2code},
  note   = {Built on Paper2Code (Seo et al., ICLR 2026)}
}

@inproceedings{seo2026paper2code,
  title     = {Paper2Code: Automating Code Generation from Scientific Papers
               in Machine Learning},
  author    = {Seo, Minju and Baek, Jinheon and Lee, Seongyun and
               Hwang, Sung Ju},
  booktitle = {International Conference on Learning Representations (ICLR)},
  year      = {2026},
  url       = {https://arxiv.org/abs/2504.17192}
}
```

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
