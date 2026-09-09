# How it works

## The problem with one-shot generation

Give a model a PDF and ask for an implementation and you get a plausible
repository. It imports cleanly, the class names match the paper's terminology,
and the training loop looks like a training loop. Three things are usually
wrong with it:

1. **It has never run.** Nothing in the generation process executed the code,
   so shape mismatches, broken masks and silent broadcasting survive.
2. **It invented numbers.** The paper did not state the warmup schedule, so the
   model wrote one. Nothing marks the difference between a value from Table 3
   and a value from nowhere.
3. **It drifted.** The attention module written first and the trainer written
   last disagree about tensor layout, because nothing froze the interface
   between them.

Every stage of this pipeline exists to prevent one of those.

## Ten stages

```
0  Ingest      paper -> paper.md            keep equations, sections, appendices
1  Plan        paper.md -> plan.md          method, data, targets, unknowns
2  Design      plan.md -> design.md         file list, frozen interfaces, shapes
3  Tasks       design.md -> tasks.md        dependency order, per-file briefs
4  Config      paper.md -> config.yaml      every value annotated with its source
5  Analyze     -> analysis/<file>.md        reason about each file before coding
6  Implement   -> the repository            one file at a time, checked each time
7  Verify      -> verify.md                 install, run, overfit a batch, debug
8  Review      -> review.md                 adversarial check against the paper
9  Package     -> README, REPRODUCTION.md   state what was and was not verified
```

## Why the stages are split this way

**Ingest is separate from planning** because extraction quality decides
everything downstream, and it is worth knowing immediately that Algorithm 1
came out of the PDF as garbage. LaTeX source is preferred over PDF for exactly
this reason: it preserves equations, table structure and section numbers, all
of which later stages cite.

**Planning produces reproduction targets**, a table mapping each of the paper's
claims to a number, a check and a feasibility verdict. Most papers cannot be
fully reproduced on the hardware at hand. Deciding that at the start — and
naming the reduced check that does run — is the difference between a
reproduction with an honest scope and one that quietly never ran.

**Design freezes the interfaces**, including a tensor shape contract for every
public function. This is the fix for drift. Files written hours apart in
different context windows agree because they were all written against the same
frozen signatures, not against each other.

**Config is its own stage** because it is where reproductions are most often
lost. A repository with an invented learning rate is indistinguishable from one
with the paper's learning rate, and it will never reproduce the results. So
every value gets a provenance comment — `# paper §5.3`, `# external: <source>`,
or `# UNSPECIFIED - <why this value>` — and the stage ends by counting how many
of each. A paper that leaves 30% of its configuration unstated is itself a
finding, and one you want before you start training.

**Analysis is separate from implementation** because reasoning about a masking
rule while simultaneously managing imports and syntax is how subtle bugs get
in. Stage 5 writes the algorithm out step by step with the tensor shape after
each one; stage 6 transcribes that into code. The two activities use different
kinds of attention and interleaving them degrades both. Analysis parallelises
across files; implementation does not.

**Verification is the reason to run this in an agent at all.** An agent can
create a virtual environment, install dependencies, run the smoke config, read
the traceback, form a hypothesis and fix the root cause. It can overfit a
single batch on purpose — which catches more implementation bugs than any other
single test, because a correct model drives loss on ten examples to near zero
and an incorrect one cannot. An API pipeline that only emits text cannot do any
of this.

**Review is adversarial and works backwards.** From the paper toward the code:
take each equation, find the lines implementing it, check it term by term. The
opposite direction — reading the code and asking whether it looks reasonable —
confirms whatever the implementation already does. Findings are graded
high/medium/low against a rubric adapted from the model-based evaluation in the
Paper2Code paper, and high and medium findings get fixed.

**Packaging records what was verified.** The generated README says, near the
top, which claims were reproduced and which were not. That sentence is what
makes the output trustworthy: a reader knows whether they are looking at a
validated reproduction or a plausible one.

## State on disk, not in context

A serious reproduction outlasts a context window. Every stage writes durable
artifacts and updates `STATE.md`, a small file holding the stage table, the
next action and the open blockers. A fresh agent with no history reads it,
reads the completed artifacts, and continues.

This is also what makes the pipeline agent-agnostic. The artifacts are plain
Markdown and YAML; nothing is serialized into a vendor's message format. You
can start a reproduction in one agent and finish it in another.

## The workspace

```
.p2c/<slug>/          plan, design, tasks, config, analysis, review, STATE
<slug>_repo/          the implementation - a normal repository you can run
```

The reproduction record and the code are kept separate, so the generated
repository is something you can publish without dragging the scaffolding along.
The parts worth keeping — `open-questions.md` and `review.md` — get copied in
during stage 9.
