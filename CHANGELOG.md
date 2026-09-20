# Changelog

All notable changes to the skills in this repository, one section per skill. The format follows [Keep a Changelog](https://keepachangelog.com/).

## ruby-writing

### [0.1.0] - 2026-09-20

#### Added

- The skill: 13 rules that no linter catches, 14 references routed by task, and 18 proof scripts that show each Ruby behavior on the installed Ruby.
- `references/rails.md`, which names the Rails method to use (37signals first, the Rails guides for facts, another method only when the project asks) and the traps that the guides document.
- `references/design-rules.md`, which carries the size limits, the no-comments rule, and the idioms worth keeping.
- Replaces the plain Ruby skills `ruby` and `sandi-metz-rules` from superpowers-ruby, and corrects their advice to use `fail`.

## ruby-quality-checking

### [0.1.0] - 2026-09-14

#### Added

- Split from `ruby-verifying`: a router over references for setup, style guides, the manual workflow, reading reports, fixing findings, concepts, tool choices, library practices, CI, team adoption, and sources.
- `scripts/setup-project`, which adds the stack to a plain Ruby project or a Rails app, tested with Minitest or RSpec, detects the project's style guide, and changes nothing on a second run. `--linter omakase|standard|rubocop` installs one when none is set up.
- `bin/verify-change`, which checks a change with lint, tests and coverage, patch coverage, Mutineer, and CRAP scores against the merge base, and stops after red tests. Lint picks `rubocop` or `standardrb` from the project's own config file and is reported, not blocking, on failure.
- `bin/crap` and `tools/crap.rb`, which score methods by complexity and coverage, with a Minitest test and an RSpec spec.
- RSpec support: detection from `spec/` with `.rspec`, `spec/spec_helper.rb`, or `spec/rails_helper.rb`, or from `Gemfile.lock`, the coverage block in `spec/spec_helper.rb`, `framework: rspec` in `.mutineer.yml`, specs mapped from changed sources, and `bundle exec rspec` in CI.
- `references/rspec-practices.md` moved to `ruby-testing`; `references/style-guides.md` and `references/tool-choices.md` are new here.

#### Fixed

- Lockfile parsing now reads dependency gems only from the `DEPENDENCIES` section and gem versions only from four-space `GEM specs:` lines, so a Bundler 4 `CHECKSUMS` section or a transitive dependency no longer misreads the test framework or a tool's version.

## ruby-testing

### [0.1.0] - 2026-09-14

#### Added

- Split from `ruby-verifying`: a router over references for writing Minitest tests and RSpec specs, collaboration tests, test data, testable design, isolation and scale, test libraries, and sources.
- `scripts/detect-tools`, a read-only report of a project's test and quality tooling, the test command, and what needs to start first. Exits 0 without a Gemfile.
- `scripts/project_profile.rb`, the detection library, kept byte-identical with the copy in `ruby-quality-checking`.
- `references/collaboration-tests.md` and `references/test-data.md`, replacing the boundary-only stubbing rule and the fixtures-over-factories preference: a project's collaboration tests and its choice of fixtures or factories are both first-class now.

## skill-creating

### [0.1.0] - 2026-09-14

#### Added

- Moved from Plastic's `docs/skill-authoring/` at commit fe1f9d2, with the Plastic-only rules left in Plastic.

## skill-evaluating

### [0.1.0] - 2026-09-14

#### Added

- Moved from Plastic's `docs/skill-authoring/` at commit fe1f9d2, with the Plastic-only rules left in Plastic.

## plain-writing

### [0.4.0] - 2026-09-19

#### Added

- A Stop hook, at `hooks/stop.rb`. It reads the reply the agent just finished from the session transcript and runs `lint.rb` over it, so prose typed straight into a session is checked by the same rules as prose written to a file. The gate only ever saw writes and publishes, which left reports, status updates, and narration unchecked.
- Three modes, held in `~/.claude/plain-writing-observe.json` so the hook can be turned off without editing `settings.json`. `observe` records a tally and never interrupts, `block` sends a turn back once with the findings and the pages that govern them, and `off` does nothing. The shipped default is `observe`, for seven days.
- The tally is bounded by construction: one entry per rule, at most three examples of 160 characters, so the file stops growing at a few kilobytes however many replies it sees. When the seven days are up the hook stops writing, and the SessionStart hook reports the counts once and asks whether to switch to `block`.

#### Changed

- `lint.rb` guards its command line behind `$PROGRAM_NAME == __FILE__`, so it can be loaded as a library. Running it as `ruby hooks/lint.rb FILE` behaves exactly as before.

### [0.3.0] - 2026-09-19

#### Added

- The SessionStart hook now ships with the skill, at `hooks/session-start.rb`. It injects the activation set (`SKILL.md`, the Google highlights page, and the personal overrides) at the start of every session. Before this the hook existed only as an unversioned file in the user's own `~/.claude/hooks/`, so a fresh install got the gate but no activation set.
- `hooks/run-hook.sh`, one POSIX shell entry point for both hooks. Claude Code registers it per event and names the hook as the first argument: `<shim> session-start` and `<shim> gate`. The shim resolves its own directory through symlinks, so an installed link keeps finding the skill it points into, and it exits 0 without output when Ruby is missing, the name is unknown, or the body is absent.

#### Changed

- The activation-set budget rose from 10,000 to 16,000 characters, and `SKILL.md` now outranks the highlights page when the set has to be cut. At 10,000 characters the three files came to 10,874, so an overrun of 8% dropped `SKILL.md` whole and the session ran without the routing table.
- Injected files lose their YAML frontmatter. The skill listing already carries the description.

### [0.2.1] - 2026-09-19

#### Fixed

- The gate now finds the skill wherever it is installed. It reads `PLAIN_WRITING_ROOT`, then `~/.claude/skills/plain-writing`, then the directory above the hook itself, which is the skill whenever the hook runs from a plugin install or a repository checkout. Before this, the gate read one hardcoded path, so a plugin install left it silent: it named no pages and reported no findings.

### [0.2.0] - 2026-09-15

#### Changed

- Renamed from `writing-style` to `plain-writing`: the skill directory, the `name` field, the marketplace entry, the hook file names, and the gate's cache directory. Install it again as `plain-writing@zalom-skills`, or rename a symlink install to `plain-writing`.

### [0.1.0] - 2026-09-14

#### Added

- `metadata.author` in the `SKILL.md` frontmatter.
- Install steps for the `zalom-skills` marketplace.

#### Changed

- Moved into this repository at `writing-style/`, with its full history from the standalone writing-style-skill repository, and listed in the marketplace.
