# writing-style

An Agent Skill that keeps AI-written text in one consistent style: a documented base layer plus your own rules on top. Point an agent at it, and prose, documentation, commit messages, and chat replies stop drifting back to filler words, borrowed jargon, and AI-sounding phrasing.

## What it does

The skill has two layers. The base layer is the full Google developer documentation style guide (70 pages, vendored under `references/google/`), covering grammar, punctuation, formatting, and naming. The overrides layer, `references/overrides.md`, is one person's rules on top: no em dashes, gendered pronouns, plain words for a non-native reader, tables for work-item listings, and more. The overrides layer wins whenever the two disagree.

`SKILL.md` is a small router, not a manual. It states the layer rule, carries a short always-on core (the handful of rules that must be right even if nothing else loads), and routes to the right base-layer page by category.

## Install

```sh
ln -s /path/to/writing-style-skill ~/.claude/skills/writing-style
```

Restart the agent session so it picks up the new skill.

## The layer model

```
references/
  overrides.md      <- your rules, checked first, wins on conflict
  google-pages.md    <- manifest: file, live URL, category (re-sync reference)
  google/             <- 70 vendored pages, the base layer, checked as fallback
```

An agent reads `references/overrides.md` for anything it covers. For everything else, it falls back to the matching page under `references/google/`.

## Make it yours

Replace the contents of `references/overrides.md` with your own rules. Nothing else in the skill needs to change: the base layer and the routing in `SKILL.md` stay as they are, and your overrides still win on every conflict.

## Where the base layer came from

The 70 pages under `references/google/` are adapted from the [Google developer documentation style guide](https://developers.google.com/style), used under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Each page keeps its own `Source:` URL line. See `NOTICE` for the full attribution.

To re-sync a page against its live version, look up its URL in `references/google-pages.md`, fetch the live page, and update the local file if it changed. The manifest is the single authority for this mapping; there is no automated fetch script, because pulling these pages accurately needs an agent's own page-reading tools, not a shell command.
