---
name: ruby-verifying
description: >
  Writes, reviews, and verifies Ruby and Rails tests. Use when writing or
  reviewing Minitest tests or RSpec specs, making Ruby code testable, choosing
  a test framework, adding patch coverage, Mutineer mutation testing, or CRAP
  scores to a project, checking a change before a push, reading those reports,
  or fixing surviving mutants. Also use when tests passed but a bug still
  shipped, or when someone asks whether the tests can be trusted.
license: MIT
metadata:
  author: Zlatko Alomerovic
---

# Ruby verifying

Write tests that check behavior, keep the code under test easy to test, and prove each change against 4 gates on the changed code only. The full suite runs in CI.

## Rules

Writing tests:

- Use Minitest by default: unit style with `assert_*`, and fixtures over factories, as Rails and 37signals do. Use RSpec only in a project that already uses it, one with `spec/` and `.rspec`, or with rspec in `Gemfile.lock`. Never mix both in one project.
- Make code testable by injection. Pass IO, `ENV`, the clock, paths, and collaborators as constructor or method arguments with real defaults. Never `eval` rewritten source or reassign global constants in a test.
- Keep every test hermetic: per-test state in `setup` instance variables or `let`, files in `Dir.mktmpdir`, and a result that holds alone and in random order.
- Assert exact values and both sides of each boundary. A direction such as `assert_operator total, :<, 54_90` or `expect(total).to be < 54_90` lets mutants survive.
- Stub only at boundaries such as the clock, randomness, and the network. In RSpec, use verifying doubles such as `instance_double`.

Verifying a change:

- Check the change, not the codebase. Run the tests for the changed files, plus the integration or system tests of each feature the change touches. Never run the full suite locally or inside an agent step. The full suite runs in CI, and a red build stops the release.
- A change passes when all 4 gates hold on the changed code: tests green, patch coverage 100% of lines and branches, mutation score 75% or more, CRAP 30 or less per changed method. The 100% applies to changed lines, not to the codebase. Skunk is a report, never a gate.
- `bundle exec bin/verify-change BASE [--test FILE]...` applies all 4 gates with Minitest or RSpec. Pass `--test` for the integration or system tests of a touched feature. Exit 0 means verified, 1 a check failed, 2 a usage or git error.
- Exercise the changed feature as well: run the command, open the page, or walk the steps of the fixed bug.
- After 2 failed attempts to kill the same survivor, stop and ask a person whether it is equivalent.

## Gotchas

- Minitest 6 rejects `assert_equal nil, value`: write `assert_nil value`. `Minitest::Mock` and `stub` need the `minitest-mock` gem.
- Mutant 0.16.3 reports every mutant alive on Ruby 4.0, and Evilution fails on Minitest 6. Use Mutineer.
- `--operators` replaces Mutineer's 5 default operators. Keep all 11 in `.mutineer.yml`.
- `strategy` is not a `.mutineer.yml` key. Pass `--strategy redefine` in plain Ruby, or `--rails` in a Rails app.
- Mutineer's `--daemon` runs Minitest only. RSpec runs in the default mode with `--framework rspec`.
- In plain Ruby with Minitest, test files need `require_relative "test_helper"`, or every mutant reads uncapturable. RSpec specs keep `require "spec_helper"`.
- `git diff` skips untracked files. Run `git add` on new files before verifying.
- SimpleCov merges recent runs. Remove `coverage/` before a partial run; `bin/verify-change` does.
- Pin RubyCritic to `~> 4.12`, because Skunk refuses 5, and add `ostruct` on Ruby 4.0. Never set `SHARE=true`: it uploads the Skunk report publicly.
- Mutineer needs Ruby 3.4 or later.

## Tasks

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. Run a script by its full path, `SKILL_DIR/scripts/...`, where `SKILL_DIR` is that directory.

| When | Do |
|---|---|
| Writing or reviewing a Minitest test, or a Minitest 5 suite that breaks on Minitest 6 | Read `references/minitest-idioms.md`. |
| Writing or reviewing an RSpec spec, changing `spec_helper.rb` or `.rspec`, or choosing between Minitest and RSpec | Read `references/rspec-practices.md`. |
| Code is hard to test: it reads `ENV`, globals, the clock, or `$stdout`, or a script runs when a test loads it | Read `references/testable-design.md`. |
| A test fails only next to others or under some seeds, leaves state behind, or the suite is too slow | Read `references/isolation-and-scale.md`. |
| A project lacks `bin/verify-change` | Run `ruby SKILL_DIR/scripts/setup-project --dry-run PROJECT_DIR`, then again without `--dry-run`, then `bundle install` in the project. Read `references/setup.md` when the script warns, keeps a file that was expected to change, or a person sets up by hand. |
| A change is ready for a push or a pull request | Run `bundle exec bin/verify-change main`. Read `references/manual-workflow.md` when running the checks one at a time or teaching a person to run them. |
| `bin/verify-change` ends with `Failed:` | Read `references/fixing-findings.md` at the section the `Failed:` line names. |
| Someone asks what a report line or a score means | Read `references/reading-reports.md` for each tool's output, and `references/concepts.md` for definitions, formulas, and worked examples. |
| A question names options, versions, or upgrades of Minitest, RSpec, SimpleCov, Mutineer, Skunk, or RubyCritic | Read `references/library-practices.md`. |
| CI is missing, red, or about to change | Read `references/ci.md`. |
| Someone proposes the stack to a team, or rolls it out on legacy code | Read `references/team-adoption.md`. |
| Someone asks where a practice comes from | Read `references/sources.md`. |

## Scripts and assets

- `ruby SKILL_DIR/scripts/setup-project [--dry-run] [--no-ci] PROJECT_DIR`: execute it, do not read it. It detects Rails and RSpec, and a second run changes nothing. Exit 0 means done, 1 a usage error, 2 no Gemfile, 3 a filesystem error, 4 an RSpec Rails app without a spec helper, 5 a Rails app with Minitest and no `test/test_helper.rb`.
- `assets/` holds the files the script copies into a project: `bin/verify-change`, `bin/crap`, `tools/crap.rb` with its Minitest test and its RSpec spec, `test/test_helper.rb`, `mutineer.yml`, `rspec`, `spec/spec_helper.rb`, the coverage blocks in `coverage/`, and the CI templates in `github/`.
