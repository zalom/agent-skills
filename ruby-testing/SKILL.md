---
name: ruby-testing
description: >
  Writes and refactors Ruby and Rails tests in the project's own framework,
  Minitest or RSpec, with its fixtures or factories and its mocking library.
  Use when writing, reviewing, or refactoring tests or specs; adding unit,
  collaboration, or integration tests; checking that a class sends the right
  message to a mailer, gateway, or job; removing shared state from specs;
  choosing Minitest or RSpec for a new project; making code testable with
  injection; fixing flaky, order-dependent, or slow tests; or when a
  Minitest 5 suite breaks on Minitest 6.
license: MIT
compatibility: Needs Ruby, Bundler, git, and a shell that can install gems from rubygems.org.
metadata:
  author: Zlatko Alomerovic
---

# Ruby testing

Write tests that check behavior and kill mutants, in whatever framework, test data style, and mocking library the project already uses.

## Rules

- Run `detect-tools` first. It reports the framework, test data, mocking library, and what has to start before tests run.
- Use the project's own framework, test data style, and mocking library. In a new project with no framework, recommend Minitest and accept RSpec.
- Copy the nearest existing test of the same kind before writing a new one from scratch.
- Say once, in the same reply, when coverage, mutation testing, or CRAP tooling is missing, then keep writing tests. The warning never blocks writing tests: never refuse or stall on it, and never run the full suite "just to be safe" instead.
- Unit tests assert the public result of an incoming query and the direct public side effect of an incoming command.
- Collaboration tests assert that an outgoing command reaches the right collaborator with the right arguments: a `Minitest::Mock` or spy, an RSpec `instance_double` with `have_received`, or a Rails helper such as `assert_enqueued_with`. An outgoing query is stubbed to return a value, not asserted as a call. Never test a private method directly. `collaboration-tests.md` has the patterns.
- Integration tests run real objects for a given input and assert the output.
- Make code testable by injection. Pass IO, `ENV`, the clock, paths, and collaborators as constructor or method arguments with real defaults. Never `eval` rewritten source or reassign global constants in a test.
- Keep every test hermetic: per-test state in `setup` instance variables or `let`, files in `Dir.mktmpdir`, and a result that holds alone and in random order.
- Assert exact values and both sides of each boundary. A direction such as `assert_operator total, :<, 54_90` or `expect(total).to be < 54_90` lets mutants survive.
- Run the test files you wrote or changed, plus the tests of the feature the change touches. Never run the full suite locally or inside an agent step, even under time pressure or for "just one line changed": the full suite runs in CI, and a red build stops the release.
- When something needs to start before tests run, start it. Never skip or delete a test because a database or a service will not start; say so and ask.
- Without a shell that can run Ruby, give the commands to run by hand and say plainly that nothing here was run or verified.

## Gotchas

- Minitest 6 rejects `assert_equal nil, value`: write `assert_nil value`. `Minitest::Mock` and `stub` need the `minitest-mock` gem.
- In plain Ruby with Minitest, test files need `require_relative "test_helper"`, or a mutation tool that forks per file reads every mutant as uncapturable. RSpec specs keep `require "spec_helper"`.
- RSpec specs need `.rspec` with `--require spec_helper`, or a bare `require "spec_helper"` line in each file.
- `minitest-around` needs the `minitest-around` gem for an `around` hook; RSpec has `around` built in.

## Tasks

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. `SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict or invent what a script prints.

| When | Do |
|---|---|
| Starting work on a project's tests, or unsure what tools it has | Run `ruby SKILL_DIR/scripts/detect-tools PROJECT_DIR`. |
| Writing or reviewing a Minitest test, or a Minitest 5 suite that breaks on Minitest 6 | Read `references/minitest-idioms.md`. |
| Writing or reviewing an RSpec spec, changing `spec_helper.rb` or `.rspec`, or choosing between Minitest and RSpec | Read `references/rspec-practices.md`. |
| Writing a test that checks a class sends a message to a collaborator: a mailer, a gateway, a job, another service | Read `references/collaboration-tests.md`. |
| Adding a test that needs data, or a project has both fixtures and factories | Read `references/test-data.md`. |
| Code is hard to test: it reads `ENV`, globals, the clock, or `$stdout`, or a script runs when a test loads it | Read `references/testable-design.md`. |
| A test fails only next to others or under some seeds, leaves state behind, or the suite is too slow | Read `references/isolation-and-scale.md`. |
| A question names options, versions, or upgrades of Minitest or RSpec themselves | Read `references/test-libraries.md`. |
| Someone asks where a testing practice comes from | Read `references/sources.md`. |
| The task is checking a change before a push, adding patch coverage or mutation testing, or reading a `Failed:` line | Use the ruby-quality-checking skill instead. |
| The task is writing a test to kill a named mutation survivor, cover an uncovered changed line, or lower a CRAP score | Use the ruby-quality-checking skill instead; that is the ruby-quality-checking skill's job, not this skill's test writing. |

## Scripts

- `ruby SKILL_DIR/scripts/detect-tools [--json] PROJECT_DIR`: read-only report of the project's tools. Never asks; never writes. Works without a Gemfile, and lists one as missing. Exit 0 prints the report, 1 a usage error, 2 `PROJECT_DIR` is not a directory.
- `scripts/project_profile.rb`: the detection library `detect-tools` uses. Read it to see exactly how a fact is detected; do not run it directly.
