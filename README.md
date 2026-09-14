# Agent skills

Skills I write for my own work, published as a Claude Code plugin marketplace. Each skill lives in its own directory at the repository root, in the Agent Skills layout: a `SKILL.md` that routes, references loaded only when a task needs them, and scripts or assets where a step must be exact.

## Skills

| Skill | What it does |
|---|---|
| `ruby-verifying` | Writes and verifies Ruby and Rails tests with Minitest or RSpec, and checks each change with SimpleCov patch coverage, Mutineer mutation testing, and CRAP scores, on the changed code only. Ships a setup script and `bin/verify-change`. |
| `writing-style` | Keeps AI-written prose, documentation, commit messages, and replies in one style: the Google developer documentation style guide, plus optional personal overrides and 2 enforcement hooks. |

## Install

```sh
claude plugin marketplace add zalom/agent-skills
claude plugin install ruby-verifying@zalom-skills
claude plugin install writing-style@zalom-skills
```

Restart Claude Code after installing. The writing-style hooks are optional and installed by hand, as its own README describes.

## Use a skill without an agent

The references are plain Markdown, written for people as well as agents.

To add the Ruby verification stack to a project that uses Minitest or RSpec:

```sh
ruby ruby-verifying/scripts/setup-project --dry-run path/to/project
ruby ruby-verifying/scripts/setup-project path/to/project
cd path/to/project
bundle install
bundle exec bin/verify-change main
```

To write better tests, read these in `ruby-verifying/references/`:

1. `minitest-idioms.md` or `rspec-practices.md`: how to write and run tests in each framework, and when to choose which.
2. `testable-design.md`: how to make code testable with dependency injection.
3. `isolation-and-scale.md`: how to keep tests independent and speed up a slow suite.

To learn the checks, read these in `ruby-verifying/references/` in this order:

1. `concepts.md`: what each check measures, with formulas and worked examples.
2. `setup.md`: what the setup script changes, and the same steps by hand.
3. `manual-workflow.md`: each check as a separate command, with real output.
4. `reading-reports.md`: what each line of each report means.
5. `fixing-findings.md`: what to do when a check fails.
6. `library-practices.md`: versions, options, and upgrade notes for each library.
7. `ci.md` and `team-adoption.md`: CI, rollout, and the case for a team.

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
