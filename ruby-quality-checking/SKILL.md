---
name: ruby-quality-checking
description: >
  Checks a Ruby or Rails change on the changed code only: lint in the
  project's style guide, green tests, patch coverage, mutation score, and
  CRAP scores. Use when checking a branch before a push or pull request;
  adding coverage, mutation testing, CRAP scores, RuboCop, Standard, or
  rubocop-rails-omakase to a project; explaining what a CRAP score,
  mutation score, or patch coverage number means; reading or fixing
  surviving mutants, uncovered lines, or high CRAP scores; writing the
  test or spec that kills a named surviving mutant; when someone asks to
  run the whole test suite to check a small change; or when tests passed
  but a bug still shipped and someone asks whether the tests can be
  trusted. For writing or refactoring tests in general, use ruby-testing.
license: MIT
compatibility: Needs Ruby, Bundler, git, and a shell that can install gems from rubygems.org.
metadata:
  author: Zlatko Alomerovic
---

# Ruby quality checking

Prove a change against 5 gates on the changed code only, in the project's own tools. The full suite runs in CI.

## Rules

- Detect and adapt: `bin/verify-change` reads the project's style guide, framework, and mutation tool before running anything.
- A change passes when all 5 gates hold on the changed code: lint clean in the project's style guide, tests green, patch coverage 100% of lines and branches, mutation score 75% or more, CRAP 30 or less per changed method. The 100% applies to changed lines, not to the codebase. Skunk is a report, never a gate.
- Recommend each goal, then its tool: lint in the project's own style guide; patch coverage with SimpleCov; mutation score with Mutineer; CRAP scores with `bin/crap`. Say what each proves. `tool-choices.md` has the full goal-to-tool table.
- Never install a style guide unasked. With no style guide, print the 3 choices (rubocop-rails-omakase, standard, rubocop) and wait to be asked by name.
- `bundle exec bin/verify-change BASE [--test FILE]...` applies all 5 gates with Minitest or RSpec. Pass `--test` for the integration or system tests of a touched feature. Exit 0 means verified, 1 a check failed, 2 a usage or git error.
- A lint failure is reported under `Failed:` but never stops the other checks. Lint is skipped, not failed, with no style guide, two style guides, no changed Ruby files, or its gem missing from `Gemfile.lock`.
- When someone asks to run the whole suite for a change, run `bin/verify-change` on the changed files instead. Do not offer the full suite as the local check, and say that the full suite runs in CI.
- Exercise the changed feature as well: run the command, open the page, or walk the steps of the fixed bug.
- After 2 failed attempts to kill the same survivor, stop and ask a person whether it is equivalent.
- When the task is writing or refactoring a test rather than fixing a finding, use the ruby-testing skill: this skill's own test writing is limited to a test that kills a named survivor, covers an uncovered changed line, or lowers a CRAP score.
- Run `setup-project` without `--dry-run` only when the person asked to add the verification stack. Otherwise run it with `--dry-run`, show what it would do, and stop there.
- Without a shell that can run Ruby, give the commands to run by hand and say plainly that nothing here was run or verified.

## Gotchas

- Mutant 0.16.3 reports every mutant alive on Ruby 4.0. Evilution 1.1.0 errors on Minitest 5.27 and 6 yet reports PASS; it works only with RSpec. Use Mutineer.
- `--operators` replaces Mutineer's 5 default operators. Keep all 11 in `.mutineer.yml`.
- `strategy` is not a `.mutineer.yml` key. Pass `--strategy redefine` in plain Ruby, or `--rails` in a Rails app.
- Mutineer's `--daemon` runs Minitest only. RSpec runs in the default mode with `--framework rspec`.
- `git diff` skips untracked files. Run `git add` on new files before verifying.
- SimpleCov merges recent runs. Remove `coverage/` before a partial run; `bin/verify-change` does.
- Skunk, RubyCritic, and Flog are optional and not part of the default setup: `bin/crap`'s CRAP gate needs only `prism`, a default gem on Ruby 3.3 and later. Add Skunk by hand for the risk report; pin RubyCritic to `~> 4.12`, because Skunk refuses 5, and add `ostruct` on Ruby 4.0. Never set `SHARE=true`: it uploads the Skunk report publicly.
- Mutineer needs Ruby 3.4 or later.
- `standardrb` reads `.standard.yml`, not `.rubocop.yml`. A `.rubocop.yml` that wires in Standard still lints with `rubocop`, not `standardrb`.

## Tasks

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. `SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict or invent what a script prints.

| When | Do |
|---|---|
| A project lacks `bin/verify-change` | Run `ruby SKILL_DIR/scripts/setup-project --dry-run PROJECT_DIR`. Show the result. Only when the person asked to add the stack, run it again without `--dry-run`, then `bundle install` in the project. Read `references/setup.md` when the script warns, keeps a file that was expected to change, or a person sets up by hand. |
| Choosing or installing a style guide | Run `setup-project --linter omakase\|standard\|rubocop`. Read `references/style-guides.md` for detection, the lint command, and ambiguous style guides. |
| A change is ready for a push or a pull request | Run `bundle exec bin/verify-change main`. Read `references/manual-workflow.md` when running the checks one at a time or teaching a person to run them. |
| `bin/verify-change` ends with `Failed:` | Read `references/fixing-findings.md` at the section the `Failed:` line names. |
| Someone asks what a report line or a score means | Read `references/reading-reports.md` for each tool's output, and `references/concepts.md` for definitions, formulas, and worked examples. |
| Picking a tool for a goal, or a mutation tool was tried and rejected | Read `references/tool-choices.md`. |
| A question names options, versions, or upgrades of SimpleCov, Mutineer, Skunk, RubyCritic, or rubocop-rspec | Read `references/library-practices.md`. |
| CI is missing, red, or about to change | Read `references/ci.md`. |
| Someone proposes the stack to a team, or rolls it out on legacy code | Read `references/team-adoption.md`. |
| Someone asks where a practice comes from | Read `references/sources.md`. |

## Scripts and assets

- `ruby SKILL_DIR/scripts/setup-project [--dry-run] [--no-ci] [--linter omakase|standard|rubocop] PROJECT_DIR`: execute it, do not read it. It detects Rails, RSpec, and the style guide with `ProjectProfile`, and a second run changes nothing. Exit 0 done, 1 usage error, 2 no Gemfile, 3 filesystem error, 4 RSpec Rails app without a spec helper, 5 Rails app with Minitest and no `test/test_helper.rb`.
- `scripts/project_profile.rb`: the detection library, identical to the copy in the ruby-testing skill; `test/skills_sync_test.rb` in this repository keeps the two in sync.
- `assets/` holds the files the script copies into a project: `bin/verify-change`, `bin/crap`, `tools/crap.rb` with its Minitest test and its RSpec spec, `test/test_helper.rb`, `mutineer.yml`, `rspec`, `spec/spec_helper.rb`, the coverage blocks in `coverage/`, and the CI templates in `github/`.
