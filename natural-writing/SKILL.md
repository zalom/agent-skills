---
name: natural-writing
description: >
  Reviews and revises prose that sounds generic, stiff, overpolished, or
  AI-written. Use when asked to make text sound more like its author,
  remove boilerplate, compare wording with AI-writing research, or explain
  why a draft does not sound like something a person would say. Applies to
  applications, emails, posts, bios, and other prose. Excludes spelling-only
  checks and software implementation.
license: MIT
metadata:
  author: Zlatko Alomerovic
---

# Natural writing

Improve the supplied prose while keeping its facts, voice, and purpose.

## Keep the author's meaning

**Edit the language without changing the account.** Preserve names, quantities,
ownership, attribution, uncertainty, and conditions that explain how something
works. Keep a real example before a generic claim about the same quality.

- Treat an approved draft as the starting point. Preserve later additions.
- Correct grammar without adding facts to resolve an ambiguous statement.
- Do not add errors, slang, invented anecdotes, metrics, or personal feelings
  to simulate human writing. Match the intended audience and existing voice.
- Treat repeated lists, stock transitions, and broad closing promises as
  candidates for editing, not forbidden forms. Keep them when they do useful work.
- Do not infer authorship from vocabulary or turn a style score into an AI
  probability. Label research findings and editorial impressions separately.

Check that every revised claim still says who did what, under which conditions.

## Use the relevant plain-writing guidance

**Apply clarity rules without forcing a documentation voice onto personal prose.**
When plain-writing is available, use its guidance on active voice, familiar
words, sentence structure, contractions, paragraphs, and clear references.
Use its formatting guidance only for elements the requested output contains.

Keep technical terms that carry meaning, conversational turns the author uses,
and useful sentence-length variation. Do not import document templates or
report requirements into a short reply. If plain-writing is unavailable, use
direct verbs, readable paragraphs, and the author's vocabulary; flag ambiguity
instead of smoothing it into an invented claim. Follow explicit user style
choices and applicable project rules.

Check that the result sounds appropriate for its speaker and audience.

## Match the requested work

**Return only the requested assessment, revision, or both.** For an ordinary
review-and-improve request, give a short finding, the few changes that matter,
and the revised text. Keep the evidence explanation brief. Create a report or
save files only when requested or required by the established deliverable.

| When | Read or use |
|---|---|
| Revising supplied prose | Read [Editing](references/editing.md). |
| Comparing wording with AI-writing research or making frequency claims | Read [Research](references/research.md); verify the sources used for the claim. |
| Jev is requested, or is available and authorized for review | Use typesafe-ai if available and read [Jev review](references/jev-review.md). |
| Working on an application or needing an example of factual preservation | Read [Application examples](references/application-examples.md). |
| Evaluating changes to this skill | Run the cases in [Evals](evals/evals.json) with skill-evaluating if available. |

Check that analysis has not displaced the text the user asked to improve.
