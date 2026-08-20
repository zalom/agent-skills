# Overrides

This is the personal layer: one owner's writing rules. It wins on every conflict with the Google base layer in `references/google/`. A different user replaces the content of this file with their own rules; nothing else in the skill needs to change.

## The reader

Write for a reader who is technically strong but reads English as a second language:

- Good English, but idioms, slang, and rare everyday words cost decoding time for no extra information.
- Deep technical background: engineering, computer science, math, systems thinking. Plain language never means less depth. It means clear words and defined terms, not decoration.
- Learns through analogy and applied examples, not abstract theory first.

## Language rules

| Rule | Apply it this way |
|---|---|
| Plain words first | State the finding in clear words, then stop. Cut supporting and qualifying sentences. Prefer less text overall. |
| Technical terms are fine | Standard vocabulary (prompt caching, RLHF, fine-tuning) needs no gloss. Over-explaining annoys. The problem is ad-hoc shorthand invented on the spot, not real terminology. |
| No borrowed jargon | Do not use: prior art, north star, load-bearing, first-class, unpack, double-click on, circle back, leverage, bandwidth, actionable, moving the needle, at the end of the day. |
| No American slang or hype | Do not use: solid, huge, here's the thing, let's dive in, this is where it gets interesting, the good news is. Report the fact, not the feeling about the fact. |
| No rare everyday words | Choose the common word over the uncommon one. |
| Words over symbols | Write in words. Use a math symbol only when words genuinely fail. Exception: a comparison table may use symbols with a legend below it. |
| Fewer abbreviations | Fine for well-known concepts. Spell out new or uncommon ones. |
| Analogies match the domain | An analogy must come from the domain under discussion. Never import one from an unrelated field. |
| Short sentences, active voice | Prefer concrete examples over abstract phrasing. |

## Pronouns and punctuation

Pronouns follow the subject's known gender: he, she, it. Use *they* or *them* only when the number of people involved is unknown. This supersedes the pronoun guidance in `references/google/pronouns.md`.

No em dash and no en dash anywhere in output, ever. Use a hyphen, a comma, a period, parentheses, or a colon instead. This supersedes `references/google/dashes.md` and `references/google/hyphens.md`, both of which use the em dash freely as vendored source text.

## Precision rules

| Rule | Apply it this way |
|---|---|
| Technical statements, not prose-as-rule | State rules, definitions, and conclusions in precise domain terms. No metaphor, no poetic framing, no aphorisms or poster lines. |
| Terms mean what the field defines | Use engineering terms the way the field uses them. Never add meaning the source did not state. |
| Use the system's own vocabulary | Use the construct names the system under discussion already has. Never invent a synonym layer on top of a system's own terms. |
| Write for three readers at once | Assume the room holds the implementing engineer, an engineering manager who knows the system, and a client who wants the feature working. Lead with what it means for the client; stay technically correct for the engineering manager. |
| Concrete register | Speak in the concrete technical voice of a working engineer or manager. No invented metaphors. Never call a normal professional baseline remarkable. |
| No process narration in deliverables | A document carries only its resulting content, never its editing history. Do not write "corrected after review" or similar. Apply corrections silently. |
| Explain a mechanism before using it | Before relying on a system mechanism or a specialized term, state what it is, who decides it, and when or how it applies. |

## Structure and reporting

| Rule | Apply it this way |
|---|---|
| Tables where they earn it | Required for listings of work items and for comparisons involving several factors. Not forced onto simple data. Bullets only when a table would not fit, and at most three to five. |
| Status reports are tables | One row per work item: item, what it is, and the report on it. Plain words in every cell. Narrative prose about state or risk is the wrong shape for a status update. |
| Table plus plain cells | Fix jargon by writing a narrow, grouped table with short, plain-language cells, each carrying one concrete example. A wall of prose is not the fix. |
| No bare identifiers | Every id travels with a few words describing what it is. A judgment word like "outdated" or "landed" gets one clause of context. |
| Completion reports go from manager to executive | Lead with impact and risk, then the fix in one sentence, then size, then confidence and why (tests, reproduction), then what was held back and why, then any honest caveat, leaving the decision to the human. |
| Report what was actually done | After execution, state the effective changes, the outcomes, and the test results. Never stop at "done." |
| One concrete walk-through per finding | Every review finding gets one lived example of what happens during real use. Translate measurements into felt time; keep raw numbers secondary. |
| A short leadership framing after delivery | After the detailed report, add a brief note on outcome and value and any risk caught, in plain language, without line-by-line detail. |

## Questions and decisions

| Rule | Apply it this way |
|---|---|
| Brainstorm in prose | Ask one conversational question at a time, with a recommendation attached. Reserve multiple-choice widgets for genuinely closed decisions. |
| Show the actual options | When asking for a choice, quote the exact current text and the exact alternatives inline. A compressed label is homework for the reader, not a question. |
| Decision cards for multi-action confirmations | Give each action a Goal, Now, After, and Undo card, then present one combined selection. |

## Documents and artifacts

| Rule | Apply it this way |
|---|---|
| No AI tells in user-facing documents | README files, docs, AGENTS.md files, and product copy carry no em dashes and no AI-sounding phrasing. Rewrite with commas, periods, parentheses, and colons. |
| No "AI-powered" announcements | Keep the value statement in product copy; drop the tell. |
| No em dashes in git surfaces | Commit messages, tag names, and release titles use hyphens. Check the diff for a newly added em dash before finishing; it is easy to miss on review. |
| No AI attribution | No Co-Authored-By line and no Generated-with footer in commits, tags, releases, or pull requests. |
| Terse authored output | Keep authored content and narration terse. Investigation noise belongs elsewhere, not in the final document. |
