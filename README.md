# writing-style

An Agent Skill that keeps AI-written text in one consistent style: a documented base layer, plus your own rules on top when you want them. Point an agent at it, and prose, documentation, commit messages, and chat replies stop drifting back to filler words, borrowed jargon, and AI-sounding phrasing.

## What it does

The base layer is the Google developer documentation style guide, adapted into 68 pages under `references/google/`, covering grammar, punctuation, formatting, and naming. On activation the agent reads the highlights page every time. The other 67 routed pages stay behind a routing table in `SKILL.md` and are opened only when a question needs them.

The overrides layer, `references/overrides.md`, is optional. It does not ship. When you create it, the agent reads it first on every activation and every line in it wins over the base layer. When it is absent, the base layer applies on its own.

`SKILL.md` is a router, not a manual. It states the layer rule, names the pages to load, quotes the guide's own escalation order, and routes the rest by category. It states no rules of its own.

## Install

```sh
ln -s /path/to/writing-style-skill ~/.claude/skills/writing-style
```

Restart the agent session so it picks up the new skill.

The symlink name matters: the harness requires a skill's directory name to match the `name` field in its `SKILL.md` frontmatter, which is `writing-style`. This repository is called `writing-style-skill` on purpose, to read clearly as a standalone project, so the symlink target name carries that translation. Do not rename the symlink.

## Make it yours

```sh
cp references/overrides.example.md references/overrides.md
```

Then replace the instructions in it with your own rules, one rule per line, in your own words. Nothing else in the skill needs to change: the base layer and the routing in `SKILL.md` stay as they are, and your rules win on every conflict.

`references/overrides.md` is listed in `.gitignore`, so it is never committed and pulling an update to this repository never overwrites it. `references/overrides.example.md` is the shipped template and carries no rules.

## The layer model

```
references/
  overrides.md          <- your rules, optional, read first, wins on conflict, not committed
  overrides.example.md  <- the shipped template for the file above
  google-pages.md       <- manifest: file, live URL, category (used for re-syncing)
  google/               <- 68 adapted pages, the base layer
```

## Machine-checkable companions

This skill is judgment applied by an agent, not a linter. Two open-source tools check overlapping ground mechanically, in CI or on a keystroke, and complement it rather than replace it:

- [Vale](https://vale.sh/) with the [`errata-ai/Google`](https://github.com/errata-ai/Google) package runs this same style guide as a set of runnable rules.
- [proselint](https://github.com/amperser/proselint) checks general usage problems that overlap with parts of this guide.

## Licensing

Two parts, two licenses:

| Part | License |
|---|---|
| The skill itself: `SKILL.md`, this README, `references/overrides.example.md`, `references/google-pages.md`, `evals/`, and everything else outside `references/google/` | MIT, Copyright (c) 2026 Zlatko Alomerovic. See `LICENSE`. |
| The pages under `references/google/` | CC BY 4.0, adapted from the [Google developer documentation style guide](https://developers.google.com/style), Copyright (c) Google LLC. See `LICENSE-CC-BY-4.0`. |

Each adapted page keeps its own `Source:` URL line. `NOTICE` carries the full attribution and the list of changes made. This project is not affiliated with, sponsored by, or endorsed by Google.

## Maintenance

`references/google-pages.md` is the manifest: it maps every file under `references/google/` to its live URL and category, and it is the single authority for that mapping.

To re-sync the base layer:

1. Fetch the live [What's new](https://developers.google.com/style/whats-new) page and compare it against `references/google/whats-new.md` to see which pages the guide changed.
2. Look up each changed page in `references/google-pages.md` to get its live URL.
3. Fetch that page and update the local file, keeping its `Source:` line.

There is no automated fetch script. Pulling these pages accurately needs an agent's own page-reading tools, not a shell command.
