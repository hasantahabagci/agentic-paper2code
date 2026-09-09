# Open questions

Every ambiguity the paper leaves, with the assumption made in its place. This
file is a deliverable: an honest reproduction that lists twelve unknowns is
more useful than a confident one that buries them.

Format, one entry per question:

## Q1. <what is ambiguous, in one line>

- **Where**: §4.2, "we train with a standard schedule"
- **Why it matters**: changes the learning rate at every step
- **Assumed**: inverse-square-root with 4000 warmup steps, matching §5.3 of
  the cited prior work
- **If wrong**: convergence speed and final score shift; the architecture is
  unaffected
- **Status**: open / resolved by <source> / confirmed with user
