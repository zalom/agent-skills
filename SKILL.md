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
license: MIT
---

# Writing style

## Layer rule

If `references/overrides.md` exists, read it first. Every line in it wins over the Google layer. If it does not exist, the Google layer alone applies.

The Google layer is the adapted Google developer documentation style guide under `references/google/`, one file per page.

Apply this skill to every text you write, including replies to the user, commit messages, and reports. The Google pages are written for documentation, but their language rules hold on every surface.

The "Break the rules" section in `references/google/about-this-guide.md` is Google's advice to human writers about the Google layer. It does not apply to `references/overrides.md`: the overrides layer has no exceptions. Do not use that section to skip a rule for convenience.

## On activation, read these

1. `references/google/about-this-guide.md`
2. `references/google/highlights.md`
3. `references/google/philosophy.md`
4. `references/overrides.md`, if that file exists

Everything else is opened on demand through the routing table below.

## Escalation order

When neither the overrides layer nor a Google page settles the question, `references/google/about-this-guide.md` states the order to follow:

1. **Project-specific style.** Style guidance specific to the project or product, including exceptions to this guide and terms relevant only to that product.
2. **This style guide.** Follow it when project-specific guidance is not explicit.
3. **Third-party references**, by the type of question:

| Type of question | Third-party reference |
|---|---|
| Spelling | Merriam-Webster. |
| Nontechnical style | The Chicago Manual of Style, 17th edition (subscription required). |
| Technical style | The Microsoft Writing Style Guide. Consider whether the guidance applies; some of it applies only to Microsoft products and interfaces. |

At multiple stages of this hierarchy it can help to look to established usage: search the project's own documentation, or check a broad language corpus. This is an aid at any stage, not a further tier below the third-party references.

## Routing table

Open `references/google/<name>.md` when the pages loaded on activation do not settle the question.

| Category | Open this when... | Files |
|---|---|---|
| Guide changelog | You need to know what changed in the guide and when. This is a changelog of edits to the guide, not a source of rules. | whats-new |
| Key resources | You are checking one term's spelling, capitalization, or usage; naming a product; or deciding code font, bold, or italics for text inside a sentence. | word-list, product-names, text-formatting |
| General principles | You are writing alt text or otherwise writing for accessibility, checking a claim for overstatement, mentioning an unreleased feature, writing for readers who translate or read English as a second language, choosing inclusive wording, deciding whether a term counts as jargon, writing prescriptive guidance, quoting or linking material you did not write, removing wording that will go stale, or choosing the voice and tone of a page. | accessibility, excessive-claims, future-features, global-audience, inclusive-documentation, jargon, prescriptive-documentation, third-party-content, timeless-documentation, voice-and-tone |
| Language and grammar | You are choosing tense, voice, an article, capitalization, a contraction, a plural, a possessive, a preposition, a pronoun, "you" against "the user", sentence order, an abbreviation, whether to describe a system as if it were a person, or the verb that describes an API element. | abbreviations, active-voice, anthropomorphism, articles, capitalization, contractions, pluralization, possessives, prepositions, present-tense, pronouns, second-person-and-first-person, sentence-structure, reference-verbs |
| Punctuation | You are placing a comma, colon, semicolon, ellipsis, parenthesis, period, quotation mark, slash, hyphen, or dash. | colons, commas, dashes, ellipses, hyphens, parentheses, periods-and-end-punctuation, quotation-marks, semicolons, slashes |
| Formatting and organization | You are formatting a date, time, phone number, number, or unit of measure; or you are structuring a heading, list, paragraph, procedure, table, note or warning, footnote, image, italicized term, or mathematical expression. | dates-times, format-examples, images, footnotes, headings, italics-terms, lists, mathematical-notation, notices, numbers, paragraph-structure, phone-numbers, procedures, tables, units-of-measure |
| Linking | You are writing link text or a cross-reference, or linking to a heading inside a page. | cross-references, headings-targets |
| Computer interfaces | You are documenting an API, writing or formatting a code sample, showing command-line syntax, naming a placeholder, naming a UI element, or mentioning code inside a sentence. | api-reference-comments, code-in-text, code-samples, code-syntax, placeholders, ui-elements |
| HTML and CSS | You are choosing between Markdown and HTML, writing HTML, or picking a semantic tag. | semantic-tagging, html-formatting, markdown |
| Names and naming | You need an example domain or example person name, a filename, or the correct handling of a trademark. | examples, filenames, trademarks |

## Finding a term in the word list

`references/google/word-list.md` is the largest page in the layer. Do not open it whole. Run:

```sh
grep -i -n "<term>" references/google/word-list.md
```

Then read the matching headword entry at the line number the grep reports. Headwords are bold and sit at the start of the entry, so searching the whole line finds multi-word terms too.

## Self-check

Before finishing a writing task, check the output against the pages you loaded on activation, not from memory:

- Every rule in `references/overrides.md` holds, if that file exists.
- The output follows the points in `references/google/highlights.md` that apply to it.
- Anything those pages did not settle was looked up in the routed page, not guessed.
- Where a routed page and `references/overrides.md` disagreed, the overrides file won.
