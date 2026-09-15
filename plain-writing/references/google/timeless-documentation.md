# Timeless Documentation

Source: https://developers.google.com/style/timeless-documentation

Timeless documentation avoids words/phrases that anchor content to a specific point in time or assume knowledge of prior/future products and features. In general, document only the current version of a product or feature — how it works right now, not how it changed from earlier versions or might change later.

This matters most for technical docs that may be read long after publication; words like *now*, *new*, and *currently* can make such docs inaccurate, outdated, or confusing over time.

| Recommended | Not recommended |
|---|---|
| "These subcommands let you interact with HTTP load balancing." | "These new subcommands let you interact with HTTP load balancing." |
| "The following command-line options aren't supported:" | "The following command-line options aren't currently supported:" |
| "The emulator supports the following filters:" | "The emulator now supports the following filters:" |

## Exception: time-stamped content
Procedural or time-stamped content — press releases, blog posts, release notes — CAN use time-based words.
- OK in a blog post: "Dataflow includes several new features."
- OK in procedural content to flag a state change after a step: "The VM goes offline soon after you send the shutdown command."

## Value of timeless writing
- Reduces ongoing maintenance to keep docs current.
- Avoids assuming the reader knows earlier product versions.

## Categories of words/phrases to avoid (in product/reference docs describing capabilities)
- **Words that make promises or reveal plans/strategy** — *at present*, *as of this writing*, *eventually* — can prematurely disclose product plans or imply upcoming change. See Documenting future features.
- **Words that are already implied** — Google's docs are assumed current unless a version is specified, so *currently*/*as of this writing* add nothing.
- **Words that go stale fast** — *soon*, *latest* — quickly become irrelevant.
- **Words assuming prior product knowledge** — *new* — if unavoidable, anchor it with a date/version: "The January 14, 2021 release of BigQuery includes a new resource panel."

### Full avoid-list for describing product/feature capabilities
as of this writing · currently · does not yet · eventually · existing · future, in the future · latest · new, newer · now · old, older · presently, at present · soon
