# Changelog

All notable changes to the skills in this repository, one section per skill. The format follows [Keep a Changelog](https://keepachangelog.com/).

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

### [0.2.0] - 2026-09-15

#### Changed

- Renamed from `writing-style` to `plain-writing`: the skill directory, the `name` field, the marketplace entry, the hook file names, and the gate's cache directory. Install it again as `plain-writing@zalom-skills`, or rename a symlink install to `plain-writing`.

### [0.1.0] - 2026-09-14

#### Added

- `metadata.author` in the `SKILL.md` frontmatter.
- Install steps for the `zalom-skills` marketplace.

#### Changed

- Moved into this repository at `writing-style/`, with its full history from the standalone writing-style-skill repository, and listed in the marketplace.
