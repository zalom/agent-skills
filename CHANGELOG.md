# Changelog

All notable changes to the skills in this repository, one section per skill. The format follows [Keep a Changelog](https://keepachangelog.com/).

## ruby-verifying

### [0.1.0] - 2026-09-14

#### Added

- The skill: a router over references for writing Minitest tests and RSpec specs, testable design, isolation and scale, setup, the manual workflow, reading reports, fixing findings, concepts, library practices, CI, team adoption, and sources.
- `scripts/setup-project`, which adds the stack to a plain Ruby project or a Rails app, tested with Minitest or RSpec, and changes nothing on a second run.
- `bin/verify-change`, which checks a change with tests and coverage, patch coverage, Mutineer, and CRAP scores against the merge base, and stops after red tests.
- `bin/crap` and `tools/crap.rb`, which score methods by complexity and coverage, with a Minitest test and an RSpec spec.
- RSpec support in both scripts: detection from `spec/` with `.rspec` or from `Gemfile.lock`, the coverage block in `spec/spec_helper.rb`, `framework: rspec` in `.mutineer.yml`, specs mapped from changed sources, and `bundle exec rspec` in CI.
- `references/rspec-practices.md`, with RSpec 3.13 practice measured on Ruby 4.0.3.

#### Changed

- Merged the `ruby-testing` skill into `verifying-ruby-changes` and renamed the result `ruby-verifying`, at the repository root.
- Brought the `ruby-testing` guidance up to Minitest 6: `Minitest::Mock` and `stub` need the `minitest-mock` gem, `assert_nil` replaces `assert_equal nil`, spec expectations need `_()`, and `MT_CPU` replaces `N`.

## writing-style

### [0.1.0] - 2026-09-14

#### Added

- `metadata.author` in the `SKILL.md` frontmatter.
- Install steps for the `zalom-skills` marketplace.

#### Changed

- Moved into this repository at `writing-style/`, with its full history from the standalone writing-style-skill repository, and listed in the marketplace.
