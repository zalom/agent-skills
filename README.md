# Agent skills

Skills I write for my own work, published as a Claude Code plugin marketplace. Each skill lives in its own directory at the repository root, in the Agent Skills layout: a `SKILL.md` that routes, references loaded only when a task needs them, and scripts or assets where a step must be exact.

## Skills

| Skill | What it does |
|---|---|
| `writing-style` | Keeps AI-written prose, documentation, commit messages, and replies in one style: the Google developer documentation style guide, plus optional personal overrides and 2 enforcement hooks. |

## Install

```sh
claude plugin marketplace add zalom/agent-skills
claude plugin install writing-style@zalom-skills
```

Restart Claude Code after installing. The writing-style hooks are optional and installed by hand, as its own README describes.

## Add a skill

1. Create `<name>/SKILL.md` with `name`, `description`, `license`, and `metadata.author` frontmatter, plus `references/` and `evals/evals.json`.
2. Add an entry to `.claude-plugin/marketplace.json` with `"source": "./<name>"` and `"strict": false`.
3. Put tests for the skill's scripts in `test/<name>/`.
4. Add a section for the skill to `CHANGELOG.md`.
5. Run the checks below.

## Development

```sh
bundle install
bundle exec rake test
claude plugin validate .
```

## Licenses

Everything is MIT-licensed, see `LICENSE`, except the adapted pages under `writing-style/references/google/`, which are CC BY 4.0 and adapted from the Google developer documentation style guide. `writing-style/NOTICE` carries that attribution.
