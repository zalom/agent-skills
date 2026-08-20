---
name: writing-style
description: >
  Governs writing style and communication quality. Use when writing or editing
  any prose, documentation, README, code comment, commit message, release
  note, report, summary, or reply to the user. Also fires on indirect
  requests that never name writing directly, such as "make this readable,"
  "tell me what you found," "clean this up," or "write the announcement."
  Applies to both authored documents and the agent's own communication with
  the user.
license: CC-BY-4.0
---

# Writing style

## Layer rule

Check `references/overrides.md` first. It is the personal layer and wins on every conflict. Fall back to the matching page in `references/google/` for anything the overrides layer does not cover. When the two disagree, the overrides layer wins.

When both the overrides layer and the matching Google page stay silent, follow the escalation order stated in `references/google/about-this-guide.md`:

1. Spelling: the first-listed spelling in Merriam-Webster.
2. Technical style: the Microsoft Writing Style Guide.
3. Anything left: established usage.

## Always-on core

Apply these even when no reference file is opened.

- No em dash and no en dash, ever. Use a hyphen, a comma, a period, parentheses, or a colon.
- Pronouns follow the subject's known gender: he, she, it. Use *they* or *them* only when the number of people is unknown.
- Plain words for a technically strong, non-native reader. No idioms, no slang, no hype. Standard technical vocabulary needs no gloss.
- Short sentences, active voice, concrete examples over abstract phrasing.
- Tables for listings of work items and for comparisons with several factors. Bullets only when a table does not fit, at most three to five.
- No AI tells and no AI attribution in user-facing text, commit messages, tags, releases, or pull requests.
- After doing work, report what was actually done: effective changes, outcomes, test results. Never stop at "done."
- These are guidelines, not rules. Depart from any of them when doing so genuinely improves the content, and stay consistent within a document once you depart.

## Routing table

Open the matching file at `references/google/<name>.md` when the always-on core is not enough for the task at hand.

| Category | Open this when... | Files |
|---|---|---|
| Introduction | Orienting to the guide itself, or explaining its purpose and philosophy. `whats-new.md` is a 1244-line changelog of edits to the guide, not a source of rules: open it only for questions about what changed and when | about-this-guide, highlights, whats-new, philosophy |
| Key resources | Looking up a specific term's usage, or deciding how to format inline code, UI text, or emphasis. `word-list.md` runs to about 24,000 tokens: grep the term first, for example `grep -i "^- \*\*<term>" references/google/word-list.md`, rather than opening the whole file | word-list, product-names, text-formatting |
| General principles | Writing for accessibility, avoiding overclaiming, writing for a non-native or global audience, keeping text from going stale, or handling third-party material | accessibility, excessive-claims, future-features, global-audience, inclusive-documentation, jargon, prescriptive-documentation, third-party-content, timeless-documentation, voice-and-tone |
| Language and grammar | Deciding tense, voice, articles, capitalization, contractions, pluralization, possessives, prepositions, pronouns, "you" versus "the user," sentence structure, or verb choice in reference docs | abbreviations, active-voice, anthropomorphism, articles, capitalization, contractions, pluralization, possessives, prepositions, present-tense, pronouns, second-person-and-first-person, sentence-structure, reference-verbs |
| Punctuation | Placing a comma, colon, semicolon, ellipsis, parenthesis, period, quotation mark, or slash. The whole `references/google/` layer is vendored source text that freely uses the banned em dash (821 occurrences across the layer, most in `references/google/dashes.md` and `references/google/hyphens.md`): the overrides layer governs actual output regardless of what a vendored page demonstrates | colons, commas, dashes, ellipses, hyphens, parentheses, periods-and-end-punctuation, quotation-marks, semicolons, slashes |
| Formatting and organization | Formatting dates, times, phone numbers, numbers, units; structuring headings, lists, paragraphs, procedures, tables, notices, footnotes, or images; using italics or mathematical notation | dates-times, format-examples, images, footnotes, headings, italics-terms, lists, mathematical-notation, notices, numbers, paragraph-structure, phone-numbers, procedures, tables, units-of-measure |
| Linking | Writing cross-references or link text, or linking to a heading | cross-references, headings-targets |
| Computer interfaces | Documenting an API, code sample, command-line syntax, placeholder, UI element, or code mentioned inline in prose | api-reference-comments, code-in-text, code-samples, code-syntax, placeholders, ui-elements |
| HTML and CSS | Choosing between Markdown and HTML, or formatting HTML and semantic tags | semantic-tagging, html-formatting, markdown |
| Names and naming | Choosing example domains and names, filenames, or handling trademarks | examples, filenames, trademarks |

## Maintenance

`references/google-pages.md` maps every file above to its live URL and category. Use it to re-sync a page against the live guide.

## Self-check

Before finishing a writing task, verify:

- No em dash and no en dash anywhere in the output.
- None of the banned jargon or hype words from `references/overrides.md` appear.
- Pronouns follow the rule: known gender, or *they* only when the number of people is unknown.
- A table is used where the always-on core requires one.
- Every specialized term is defined at first use.
