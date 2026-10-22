# Agent skills

Skills I write for my own work, using the portable [Agent Skills format](https://agentskills.io/specification). Install them across coding agents with the `skills` command, or through the Claude Code plugin marketplace. Each skill lives in its own directory at the repository root: a `SKILL.md` that routes, references loaded only when a task needs them, and scripts or assets where a step must be exact.

## Skills

| Skill | What it does |
|---|---|
| `ruby-testing` | Writes and refactors Ruby and Rails tests in the project's own framework, Minitest or RSpec, with its fixtures or factories and its mocking library. Ships a read-only `detect-tools` report. |
| `ruby-quality-checking` | Checks a Ruby or Rails change on the changed code only: lint in the project's style guide, green tests, SimpleCov patch coverage, Mutineer mutation testing, and CRAP scores. Ships a setup script and `bin/verify-change`. |
| `plain-writing` | Keeps AI-written prose, documentation, commit messages, and replies in one style: the Google developer documentation style guide, plus optional personal overrides and 2 enforcement hooks. |
| `skill-creating` | Authors or revises an Agent Skill, a subagent or agent role file, or a lifecycle hook with progressive disclosure. |
| `skill-evaluating` | Evaluates skills for correctness, convention compliance, and progressive disclosure. |
| `c4-model-diagramming` | Draws C4 model diagrams as standalone SVG with a title and a key: system context, container, component, system landscape, dynamic, and deployment. Ships the drawing script, every key element, and one example per type. | <!-- lint-ok: shorthand; C4 is the name of the model -->
| `report-writing` | Writes an evidence-led report, design proposal, analysis, or take-home answer as a linear HTML document with numbered pages, figures, and tables, checked in a browser and by a reviewer before it ships. Ships the page template. |

## Install

Choose one installation route per agent to avoid duplicate skills. For example, keep existing Claude Code plugins and select only `codex` in the portable installer.

### Install across coding agents

Use the [skills command](https://github.com/vercel-labs/skills/blob/main/docs/commands.md) to discover and install skills from this repository. These examples use the verified version, 1.7.4, which requires Node.js 22.20 or later.

Preview the available skills:

```sh
npx skills@1.7.4 add zalom/agent-skills --list
```

Install every skill for Codex and Claude Code across your projects:

```sh
npx skills@1.7.4 add zalom/agent-skills --global --agent codex claude-code --skill '*'
```

Keep the default symlink method: Codex reads the shared copy in `~/.agents/skills/`, and Claude Code receives links in `~/.claude/skills/`. Use `--copy` when the filesystem does not support symlinks. Omit `--global` for a project installation, or add `--yes` for an unattended command. Other agent names are listed in the [supported agents reference](https://github.com/vercel-labs/skills/blob/main/docs/agents.md).

The command installs the skills available when it runs; it does not watch the repository. Rerun it to discover and install newly added skills. To list or update skills already installed through this route:

```sh
npx skills@1.7.4 list --global
npx skills@1.7.4 update --global report-writing c4-model-diagramming
```

Replace the names in the update command with the skills you want to update. Updates for Claude Code plugins use the marketplace commands below. Installing a skill makes its instructions and supporting files available; it does not register optional hooks or copy agent settings. See the [plain-writing hook setup](plain-writing/README.md) for those steps.

This installation does not schedule updates. For unattended updates, use your operating system's scheduler to run a command such as:

```sh
npx --yes skills@1.7.4 update --global --yes report-writing c4-model-diagramming
```

Use `--global` to keep the update scope independent of the working directory, and name only the skills you want updated. Updating installed skills does not install newly added skills; use the `add` command for those.

Codex detects local skill changes automatically; it does not fetch this repository. Restart it if a skill does not appear. Check Claude Code in a fresh session after installation.

### Use a local checkout

From the repository root, replace the GitHub source with `.` to install local files:

```sh
npx skills@1.7.4 add . --global --agent codex --skill report-writing
```

This installs a snapshot of the local skill. Rerun the command after edits. For live authoring, a direct symlink from an agent's skill directory to the checkout keeps edits visible without reinstalling. Keep existing development links out of broad install or update commands, which can replace them.

### Install Claude Code plugins <!-- lint-ok: heading-case; Claude Code is a product name. -->

Use this route when you want Claude Code to manage skill versions through its plugin marketplace:

```sh
claude plugin marketplace add zalom/agent-skills
claude plugin install ruby-testing@zalom-skills
claude plugin install ruby-quality-checking@zalom-skills
claude plugin install plain-writing@zalom-skills
claude plugin install skill-creating@zalom-skills
claude plugin install skill-evaluating@zalom-skills
claude plugin install c4-model-diagramming@zalom-skills
claude plugin install report-writing@zalom-skills
```

Update the marketplace and an installed plugin with:

```sh
claude plugin marketplace update zalom-skills
claude plugin update report-writing@zalom-skills
```

Replace `report-writing` with the plugin to update. Restart Claude Code after installing or updating. The plain-writing hooks are optional and installed by hand, as its own README describes.

Claude Code also supports [automatic plugin updates](https://code.claude.com/docs/en/discover-plugins#keep-plugins-updated). They are off by default for custom marketplaces such as `zalom-skills`. To enable them, run `/plugin`, open the **Marketplaces** tab, select **zalom-skills**, and select **Enable auto-update**. Claude Code updates installed plugins after a session starts; restart to load the updated versions. This setting applies to marketplace plugins, not to portable installations or development links.

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
