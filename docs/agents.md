# Running it in your agent

The pipeline is Markdown. Anything that can read files, write files and run
commands can execute it. Below are the setups people actually use.

## Claude Code

**As a plugin** (one command, works in every project):

```
/plugin marketplace add hasantahabagci/agentic-paper2code
/plugin install agentic-paper2code@hasantahabagci
```

**Or into a project:**

```bash
git clone https://github.com/hasantahabagci/agentic-paper2code
./agentic-paper2code/install.sh --project /path/to/your/project
```

**Or for every project on the machine:**

```bash
./install.sh --global
```

Either way you get:

| Command | What it does |
|---|---|
| `/p2c:run <paper>` | the whole pipeline, with check-ins |
| `/p2c:status` | progress of every reproduction in the project |
| `/p2c:resume` | continue where the last session stopped |
| `/p2c:ingest` … `/p2c:package` | one stage at a time |

Plus a `paper2code` skill that triggers on requests like "implement this arXiv
paper", and three subagents: `paper-analyst` (stage 5, run one per file in
parallel), `paper-implementer` (stage 6), and `fidelity-reviewer` (stage 8,
best run with no memory of having written the code).

## Codex CLI

```bash
./install.sh --codex
```

This copies three prompts into `~/.codex/prompts/`:

```
/paper2code 1706.03762
/paper2code-resume
/paper2code-status
```

Codex also reads `AGENTS.md`, so a project installed with `install.sh` works
without the prompts too — just ask it to reproduce a paper.

## Cursor, Windsurf, Zed, Gemini CLI, opencode, Copilot agent mode

All of these read an agent instructions file at the repository root. Install
into the project:

```bash
./install.sh --project .
```

That writes (or appends to) `AGENTS.md` with a pointer to the toolkit. Then ask
in plain language:

> Reproduce arXiv 1706.03762 following the pipeline in `.p2c/toolkit/AGENTS.md`.

For Gemini CLI, either add `AGENTS.md` to `contextFileName` in
`.gemini/settings.json`, or copy the pointer into `GEMINI.md`. For Cursor, the
same content works as a rule under `.cursor/rules/`.

## Any other agent

There is no framework to integrate with. Give the agent one instruction:

> Follow `prompts/shared/rules.md`, then run the stages `prompts/00-ingest.md`
> through `prompts/09-package.md` in order, writing artifacts to `.p2c/<slug>/`
> and updating `STATE.md` after each stage.

## What the agent needs to be able to do

- **Read files, write files, run shell commands.** Required. Stage 7 installs
  dependencies and runs the code.
- **Fetch a URL.** Needed only to pull a paper from arXiv; you can also hand it
  a local PDF.
- **Read PDFs.** Helpful. Without it, install `poppler-utils` for `pdftotext`,
  or feed the LaTeX source instead — which is better anyway.
- **Subagents.** Optional. They make stage 5 parallel and stage 8 more
  trustworthy, but every stage runs fine in a single thread.

## A note on model choice

Stages 1, 2, 5 and 8 are the ones that decide whether the reproduction is
faithful; they are reasoning-heavy and worth your strongest model. Stage 6 is
mostly transcription from the analysis, and stage 7 is debugging. If your agent
lets you vary the model per subagent, spend the capability on analysis and
review.
