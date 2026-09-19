# plain-writing

An Agent Skill that keeps AI-written text in one consistent style: a documented base layer, plus your own rules on top when you want them. Point an agent at it, and prose, documentation, commit messages, and chat replies stop drifting back to filler words, borrowed jargon, and AI-sounding phrasing.

## What it does

The base layer is the Google developer documentation style guide, adapted into 68 pages under `references/google/`, covering grammar, punctuation, formatting, and naming. On activation the agent reads the highlights page every time. The other 67 routed pages stay behind a routing table in `SKILL.md` and are opened only when a question needs them.

The overrides layer, `references/overrides.md`, is optional. It does not ship. When you create it, the agent reads it first on every activation and every line in it wins over the base layer. When it is absent, the base layer applies on its own.

`SKILL.md` is a router, not a manual. It states the layer rule, names the pages to load, quotes the guide's own escalation order, and routes the rest by category. It states no rules of its own.

## Install

As a Claude Code plugin, from the `zalom-skills` marketplace:

```sh
claude plugin marketplace add zalom/agent-skills
claude plugin install plain-writing@zalom-skills
```

Or, from a clone of [zalom/agent-skills](https://github.com/zalom/agent-skills), link the skill directory where your agent looks for skills:

```sh
ln -s /path/to/agent-skills/plain-writing ~/.claude/skills/plain-writing
```

Restart the agent session so it picks up the new skill. The harness requires a skill's directory name to match the `name` field in its `SKILL.md` frontmatter, so keep the link named `plain-writing`.

## Make it yours

```sh
cp references/overrides.example.md references/overrides.md
```

Then replace the instructions in it with your own rules, one rule per line, in your own words. Nothing else in the skill needs to change: the base layer and the routing in `SKILL.md` stay as they are, and your rules win on every conflict.

`references/overrides.md` is listed in `.gitignore`, so it is never committed and pulling an update to this repository never overwrites it. `references/overrides.example.md` is the shipped template and carries no rules.

The plugin install keeps each version in its own cache directory, such as `~/.claude/plugins/cache/zalom-skills/plain-writing/0.1.0/`, so an overrides file created there stays behind when the plugin updates. To keep your rules across updates, use the symlink install from a clone and create the file there.

## The layer model

```
references/
  overrides.md          <- your rules, optional, read first, wins on conflict, not committed
  overrides.example.md  <- the shipped template for the file above
  google-pages.md       <- manifest: file, live URL, category (used for re-syncing)
  google/               <- 68 adapted pages, the base layer
hooks/
  run-hook.sh           <- one shell entry point; names the hook as its first argument
  session-start.rb      <- injects the activation set at the start of a session
stop.rb               <- checks the reply the agent just finished, in the session itself
  gate.rb               <- names the routed pages a draft needs, at the moment it is written
  lint.rb               <- checks the rules a machine can decide, on every write
```

## Enforcement hooks

The routing table asks an agent to open a page when it needs one. An agent that believes the skill is already loaded will skip that step and report the skill as applied, which is the failure these optional hooks exist to close. Neither replaces the judgment in the skill. They make the mechanical half hold whether or not anything was read.

`hooks/session-start.rb` runs once, when a session begins. It injects the activation set the skill asks for: your `references/overrides.md`, `SKILL.md`, and the Google highlights page, in that order of priority. The set is capped at 16,000 characters; a file that does not fit is named in a notice rather than truncated, so the agent knows to open it. YAML frontmatter is stripped from each file. When the skill directory holds no `references/overrides.md`, the hook reads `~/.claude/plain-writing-overrides.md` instead, so your own layer never has to live inside an installed copy.

`hooks/gate.rb` runs before a tool writes or publishes. It reads the draft, works out which devices the text actually uses, and names the pages that govern them with their paths, so the agent knows the guide holds more than its session does and opens what it has not read. No page text is injected, so nothing from the guide sits in context for the rest of the session. A document is pointed at a given page set once per session; checker findings are reported on every call. Tool calls made by a subagent are skipped entirely, keyed on the `agent_id` field Claude Code sets in the hook input for them.

`hooks/stop.rb` runs when a reply is finished. The gate sees a document only when a tool writes or publishes it, so a report, a status update, or any other prose typed straight into the session is seen by nothing. This hook reads that reply from the session transcript and runs the checker below over it.

It has three modes, held in `~/.claude/plain-writing-observe.json`, so it can be turned off without editing your agent's settings:

- **`observe`**: it records what it found and never interrupts. This is the default, and it lasts seven days.
- **`block`**: it sends the turn back once, with the findings and the pages that govern them. A turn is never sent back twice.
- **`off`**: it does nothing.

The record is a tally, not a log: one entry per rule, with a count and at most three examples, so the file stops growing at a few kilobytes however many replies it sees. When the seven days are up the hook stops writing, and the SessionStart hook reports the counts once and asks whether to switch to `block`.

`hooks/lint.rb` decides what a page cannot. It reads a file and reports every rule below that the text breaks:

| Rule | What it catches |
|---|---|
| `dashes` | An em dash or en dash where the overrides layer asks for a hyphen |
| `spelling` | British spellings, against the guide's Merriam-Webster reference |
| `heading-levels` | A skipped level, such as an `h4` directly under an `h2` |
| `heading-case` | A heading in Title Case rather than sentence case |
| `heading-gerund` | A heading opening with an `-ing` form |
| `heading-link` | A link inside a heading |
| `heading-number` | A sequence number written into heading text |
| `heading-empty` | A heading with no text |
| `table-caption` | A table with no `caption` element |
| `table-scope` | A `th` cell with no `scope` attribute |
| `table-merge` | `colspan` or `rowspan` in a data table |
| `cell-br` | `br` used as structure inside a table cell |
| `numbers` | A number of 10 or greater spelled out, outside sentence-initial position |

Run it on its own at any time:

```sh
ruby hooks/lint.rb README.md
```

Both hooks are reached through one entry point, `hooks/run-hook.sh`, which takes the hook name as its first argument. Symlink that one file where your agent looks for hooks and register it per event. For Claude Code that is `~/.claude/settings.json`:

```sh
ln -s "$PWD/hooks/run-hook.sh" ~/.claude/hooks/plain-writing
```

```json
{ "hooks": {
  "SessionStart": [ { "hooks": [ { "type": "command",
    "command": "~/.claude/hooks/plain-writing session-start" } ] } ],
  "Stop": [ { "hooks": [ { "type": "command",
  "command": "~/.claude/hooks/plain-writing stop" } ] } ],
"PreToolUse": [ { "matcher": "Artifact|Write|Edit|NotebookEdit",
    "hooks": [ { "type": "command",
      "command": "~/.claude/hooks/plain-writing gate" } ] } ] } }
```

The shim is POSIX shell, so it runs anywhere. It resolves its own directory through the symlink, which is how it finds the skill it belongs to, and it exits 0 without output when Ruby is missing, the hook name is unknown, or the body is absent.

Three properties are deliberate. Findings are advisory, so nothing is ever blocked; `BLOCKING_TOOLS` in `gate.rb` is the switch that makes a listed tool refuse instead, and it ships empty. A rule the guide genuinely permits in context is silenced by writing `lint-ok: <rule>` on that line, so an exception is recorded rather than taken quietly. And every failure path fails open: bad input, a missing checker, or a broken cache lets the tool call proceed untouched.

## Machine-checkable companions

The hooks above cover the rules this repository can decide. Two open-source tools check overlapping ground, in CI or on a keystroke, and complement the skill rather than replace it:

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
