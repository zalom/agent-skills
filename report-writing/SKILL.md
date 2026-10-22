---
name: report-writing
description: "Writes an evidence-led report, design proposal, analysis, or take-home answer as a linear HTML document with numbered pages, figures, and tables, checked in a browser and by a reviewer before it ships. Use when asked for a report, a design proposal, a design review document, an analysis write-up, a take-home deliverable, or a document to publish as an artifact or share as a package, and also when asked to write up the findings, prepare something for a review meeting, or turn research into a document."
license: MIT
metadata:
  author: Zlatko Alomerovic
---

# Report writing

Write the report as one argument built from evidence, laid out as a linear document that
reads the same on screen and in print, with figures and tables doing the explaining. This
body holds the rules every report follows; the references hold the story shape, the page
style, the figures, the checks, and the publishing steps.

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. `SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict or invent what a script prints.

## Gotchas

- A reference to a figure or table mid-sentence is lowercase: "figure 4", "table 2". The
  caption itself starts with "Figure 4." or "Table 2."
- An AI model is a "language model" in every sentence, never a bare "model".
- Every table has a `<caption>` with its number; every figure is a `<figure>` with a
  `<figcaption>`. A table or figure without a number cannot be referred to.
- A figure that overflows the column, a label over a box, or a page that breaks inside a
  table never shows in the source. Render the document in a browser before it ships.
- The published copy is built from the source by rewriting links. It is never edited by
  hand, and the artifact is published from the copy, never from the source whose links name
  files.
- The method's own vocabulary stays out of the document: no method names, no decision
  records, no revision history, no tracking ids. The document says what is.

## Rules (hold even when no reference is opened)

- **Tell one story.** Context and source data first, then the business rules, then the
  sample analysis, then the concrete answers, then the questions that remain. The problem is
  established before any solution is proposed, and a later change is justified by feedback
  or validation, never by preference.
- **Keep facts, interpretations, and unknowns apart.** An answer is given under explicit
  assumptions, and its caveat or its resolving question sits beside it, not in a section at
  the end. A general rule is separate from a finding about one sample. Identifiers,
  quantities, statuses, and conclusions never share a cell or a sentence.
- **Ask questions that advance the work.** A question names a definition, a source, an
  owner, an update frequency, or a condition that changes an answer, and says what changes
  when it is answered. Questions are grouped by what raised them: a rule, a sample, or an
  answer.
- **Invent nothing.** Exact user questions, agreed labels, field names, and source
  references are kept as given. No condition, operational problem, or impact figure appears
  without a source. A missing fact is written as missing.
- **Lay the page out linearly.** One column, numbered pages, sections with a purpose,
  generous whitespace, and one style for screen and print. No cards, no side-by-side content
  columns, no decoration.
- **Explain visually first.** A diagram where it clarifies a relationship or a workflow, a
  table for a comparison, a rule set, evidence, or a conclusion, then the least prose that
  carries the rest. Captions are short. Deeper detail is optional: an expander or a linked
  supporting document. Prose never repeats a table.
- **Draw architecture in C4 views** <!-- lint-ok: shorthand; C4 is the name of the model -->
  with the `c4-model-diagramming` skill, choosing the view that explains the decision at
  hand.
- **Write in the document's voice.** Neutral, no first person, in the `plain-writing` style.
  American spelling, numerals from 10 up.
- **Adapt the length.** An accepted report is a reference for shape and style, not a page
  limit or a template to fill.
- **Improve the accepted original.** When a report already exists, keep its structure and
  styling, apply each concrete finding, and check the whole document after the edit, not
  only the changed page.
- **Check before it ships.** Lint the prose, render every page in a browser, and have a
  reviewer model read the document, with primary evidence deciding every factual point.
- **Publish in step.** The artifact, its on-disk published copy, the manifest, and the
  package hold the same bytes. A change to one is a change to all four in one pass.

## Route the task to its reference

| Task | Open |
|---|---|
| Ordering the argument, separating facts from unknowns, writing the questions | `references/story.md` |
| The page: type, palette, pages, tables, figures, expanders, print | `references/layout.md` |
| Choosing, numbering, captioning, and placing a figure | `references/figures.md` |
| Checking before it ships: lint, browser render, reviewer model | `references/checking.md` |
| Publishing: artifact copies, manifest, package, links file, live-versus-disk check | `references/publishing.md` |
| Starting a new document from the page template | `assets/report-page.html` |
