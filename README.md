# Agent skills

Skills I write for my own work, published as a Claude Code plugin marketplace. Each skill lives in its own directory at the repository root, in the Agent Skills layout: a `SKILL.md` that routes, references loaded only when a task needs them, and scripts or assets where a step must be exact.

## Skills

| Skill | What it does |
|---|---|
| `ruby-writing` | Writes plain Ruby that is right on the first draft: the rules that no linter catches, such as declared hooks that raise `NoMethodError`, `private` over `protected`, and `and` never used for a value. Ships a proof script for each rule, and names the Rails method to use: 37signals first. |
| `ruby-testing` | Writes and refactors Ruby and Rails tests in the project's own framework, Minitest or RSpec, with its fixtures or factories and its mocking library. Ships a read-only `detect-tools` report. |
| `ruby-quality-checking` | Checks a Ruby or Rails change on the changed code only: lint in the project's style guide, green tests, SimpleCov patch coverage, Mutineer mutation testing, and CRAP scores. Ships a setup script and `bin/verify-change`. |
| `plain-writing` | Keeps AI-written prose, documentation, commit messages, and replies in one style: the Google developer documentation style guide, plus optional personal overrides and 2 enforcement hooks. |
| `skill-creating` | Authors or revises an Agent Skill, a subagent or agent role file, or a lifecycle hook with progressive disclosure. |
| `skill-evaluating` | Evaluates skills for correctness, convention compliance, and progressive disclosure. |

## Install

```sh
claude plugin marketplace add zalom/agent-skills
claude plugin install ruby-writing@zalom-skills
claude plugin install ruby-testing@zalom-skills
claude plugin install ruby-quality-checking@zalom-skills
claude plugin install plain-writing@zalom-skills
claude plugin install skill-creating@zalom-skills
claude plugin install skill-evaluating@zalom-skills
```

Restart Claude Code after installing. The plain-writing hooks are optional and installed by hand, as its own README describes.

## Use a skill without an agent

The references are plain Markdown, written for people as well as agents.

To read a project's test and quality tooling:

```sh
ruby ruby-testing/scripts/detect-tools path/to/project
```

To add the Ruby quality-checking stack to a project that uses Minitest or RSpec:

```sh
ruby ruby-quality-checking/scripts/setup-project --dry-run path/to/project
ruby ruby-quality-checking/scripts/setup-project path/to/project
cd path/to/project
bundle install
bundle exec bin/verify-change main
```

To write better tests, read these in `ruby-testing/references/`:

1. `minitest-idioms.md` or `rspec-practices.md`: how to write and run tests in each framework, and when to choose which.
2. `collaboration-tests.md`: how to test that a class sends the right message to a collaborator.
3. `test-data.md`: fixtures, factories, and a project with both.
4. `testable-design.md`: how to make code testable with dependency injection.
5. `isolation-and-scale.md`: how to keep tests independent and speed up a slow suite.

To learn the checks, read these in `ruby-quality-checking/references/` in this order:

1. `concepts.md`: what each check measures, with formulas and worked examples.
2. `setup.md`: what the setup script changes, and the same steps by hand.
3. `style-guides.md`: how a style guide is detected, installed, and linted.
4. `manual-workflow.md`: each check as a separate command, with real output.
5. `reading-reports.md`: what each line of each report means.
6. `fixing-findings.md`: what to do when a check fails.
7. `tool-choices.md` and `library-practices.md`: which tool for which goal, and versions and upgrade notes.
8. `ci.md` and `team-adoption.md`: CI, rollout, and the case for a team.

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

Everything is MIT-licensed, see `LICENSE`, except the adapted pages under `plain-writing/references/google/`, which are CC BY 4.0 and adapted from the Google developer documentation style guide. `plain-writing/NOTICE` carries that attribution.
