# Library practices

Facts about each library at the pinned versions, taken from its own README, changelog, and source, and from runs on Ruby 4.0.3. Open the section for the library a question about options, versions, or upgrades names.

## Contents

- Versions that work on Ruby 4.0
- Minitest 6
- RSpec 3.13
- SimpleCov 1.3
- Mutineer 1.0
- Skunk and RubyCritic
- Mutation tools that failed
- Sources

## Versions that work on Ruby 4.0

| Gem | Pin | Measured | Note |
|---|---|---|---|
| minitest | `~> 6.0` | 6.0.6 | Rails 8.1.3 runs on it. |
| minitest-mock | `~> 5.27` | 5.27.0 | Holds `Minitest::Mock` and `stub` for Minitest 6. |
| minitest-around | `~> 0.6` | 0.6.0 | Ran green on Minitest 6.0.6. |
| minitest-parallel_fork | `~> 2.1` | 2.1.1 | Ran green on Minitest 6.0.6. |
| rspec | `~> 3.13` | 3.13.2 | rspec-core 3.13.6, rspec-expectations 3.13.5, rspec-mocks 3.13.8, rspec-support 3.13.7. Printed no Ruby warnings. |
| rubocop-rspec | `~> 3.10` | 3.10.2 | Ran with RuboCop 1.91.0 as a plugin. |
| simplecov | `~> 1.3` | 1.3.0 | Ships the `simplecov` command line tool. |
| mutineer | `~> 1.0` | 1.0.0 | Needs Ruby 3.4 or later. Runs Minitest and RSpec. Young, so keep the pin. |
| skunk | `~> 0.5` | 0.5.4 | Refuses RubyCritic 5. |
| rubycritic | `~> 4.12` | 4.12.0 | Its README lists Ruby 3.3 as the newest; it ran on 4.0.3. |
| flog | `~> 4.9` | 4.9.4 | Used by RubyCritic. |
| ostruct | `~> 0.6` | 0.6.3 | RubyCritic needs it, and Bundler loads it on Ruby 4.0 only when the Gemfile lists it. |

## Minitest 6

Changes that break a Minitest 5 suite (6.0.0, December 2025):

- `assert_equal nil, value` fails. Write `assert_nil value`. Since 6.0.3, `assert_same nil, value` fails too.
- `Minitest::Mock` and `stub` moved to the `minitest-mock` gem. Add that gem when a test uses them.
- Spec expectations are gone from `Object`. Write `_(value).must_equal 3`, not `value.must_equal 3`.
- The `MiniTest` alias is gone. Write `Minitest`.
- Plugins load only when required. Require each plugin in the test helper, or call `Minitest.load_plugins`.
- `N` no longer sets the number of parallel workers. Set `MT_CPU`.
- `assert_send` is gone. Use `assert_predicate` or `assert_operator`.
- `--name` still filters tests, but `--include` replaces it.

Additions worth using:

- `bundle exec minitest test/refund_test.rb:13` runs the test on that line.
- `bundle exec minitest --bisect` finds the test that makes another test fail when they run in order.
- `rake test:fu` runs only tests with uppercase `FU` in their name, since 6.0.1.

Writing idioms and assertions that kill mutants: `minitest-idioms.md`.

## RSpec 3.13

- This skill targets RSpec 3.13. When it was measured, `4.0.0.beta1` was the only 4.x release.
- rspec-rails 8.0 needs Rails 7.2 or later, according to the [rspec-rails changelog](https://github.com/rspec/rspec-rails/blob/main/Changelog.md). This skill did not run rspec-rails.
- Configuration, `let`, doubles, and the command line options: `rspec-practices.md`.

## SimpleCov 1.3

Setup:

- Start SimpleCov before any application code loads: the top of `test/test_helper.rb` or `spec/spec_helper.rb`, and in Rails before `require_relative "../config/environment"`.
- `cover "{app,lib,tools}/**/*.rb"` includes files no test loads, so an untested file reads 0% instead of vanishing.
- Rails parallel workers each need their own name: `parallelize_setup { |worker| SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}" }` and `parallelize_teardown { |_worker| SimpleCov.result }`.
- SimpleCov merges recent runs. Remove `coverage/` before a partial run.

The 1.x names for legacy settings (the old spellings print deprecation warnings):

| Legacy | 1.3 |
|---|---|
| `add_filter` | `skip` |
| `track_files` | `cover` |
| `add_group` | `group` |
| `use_merging` | `merging` |
| `enable_for_subprocesses` | `merge_subprocesses` |
| `enable_coverage_for_eval` | `enable_coverage :eval` |
| `minimum_coverage_by_file` | `coverage(:line) { minimum 70, per: :file }` |

`deprecations :raise` turns a legacy spelling into an error once a project has migrated.

Thresholds live in a block per criterion:

```ruby
SimpleCov.start do
  coverage :line do
    minimum 90
    maximum_drop 1
    maximum_missed 5, per: :file
  end
  coverage :branch, minimum: 80, ignore: :implicit_else
end
```

The command line tool reads `coverage/coverage.json`:

| Command | What it answers |
|---|---|
| `simplecov patch --base main --minimum 100` | Are the changed lines covered? Exits non-zero below the minimum. Measured on the demo refund change: 13 of 13 lines, 12 of 12 branches. |
| `simplecov patch --base main --annotate github` | The same result as pull request annotations. |
| `simplecov show lib/refund.rb --uncovered-only` | Which lines of this file never ran? |
| `simplecov uncovered --missing` | Which files are worst, with the missed line ranges? |
| `simplecov tests lib/refund.rb` | Which tests run this file? Needs `track_tests`. |
| `simplecov ratchet` | Writes per-file floors to `.simplecov_baseline.yml`. Floors only tighten. |

`track_tests` also tints lines that ran only while loading, so loaded code stops passing for tested code. Recording costs a snapshot per test and more with branch coverage on.

`simplecov affected --base main` selects tests from a `track_tests` recording. In a measured run it fell back to the full suite as soon as the diff held a file with no coverage data, such as a YAML file, so `bin/verify-change` maps tests by file name instead.

## Mutineer 1.0

Operators:

- Tier 1 runs by default: `arithmetic`, `comparison`, `boolean_connector`, `boolean_literal`, `statement_removal`.
- Tier 2 is opt-in: `return_nil`, `literal_mutation`, `condition_negation`, `string_literal`, `regex`, `collection_method`.
- `--operators` replaces the default set. List all 11, in `.mutineer.yml`. On the demo checkout, the 6 tier 2 operators alone made 52 mutants and all 11 made 72.

Configuration:

- `.mutineer.yml` accepts `operators`, `threshold`, `jobs`, `only`, `require`, `boot`, `rails`, `daemon`, `framework`, `test_command`, `since`, and `ignore`. The 1.0.0 source also accepts `verbose`, `baseline`, and `fail_fast`. Command line flags override the file.
- `strategy` is not a configuration key. Pass `--strategy redefine` on the command line for plain Ruby. It replaces only the mutated method, the way `--rails` does, where the default `reload` re-reads the whole file. Either strategy can print "already initialized constant" warnings; they do not change the results.
- Add `.mutineer/` to `.gitignore`. It holds the coverage cache.

Frameworks:

- `framework: rspec` in `.mutineer.yml`, or `--framework rspec`, runs RSpec. Without either, Mutineer picks RSpec when most `--test` files end in `_spec.rb`, and Minitest otherwise.
- RSpec is not a Mutineer dependency. It comes from the project's bundle.
- `--daemon` supports Minitest only, and exits 2 with RSpec.
- Measured on a plain Ruby RSpec project: a spec with `be < 50_00` let 4 of 10 mutants survive, and exact `eq` expectations killed all 10. `manual-workflow.md` shows the output.

Runs:

- `--since REF` mutates only lines changed since `REF`. `--no-since` overrides a configured `since`.
- `--threshold 75` exits 1 below the score. Since 0.11.4 it also exits 1 when more than 10% of attempted mutants produce no verdict, so a broken run cannot pass.
- Mutineer loads each test file in its own process. In plain Ruby with Minitest, `require "test_helper"` fails there and every mutant reads uncapturable. Use `require_relative`. RSpec specs keep `require "spec_helper"`, because RSpec puts `spec/` on the load path.
- `--format json --output FILE` writes the report. Progress goes to stderr, so never merge the streams when parsing. Each entry in `survivors` has `id`, `subject`, `file`, `line`, `operator`, and `diff`.
- `--format html` writes a single-file report. `--dry-run` lists the mutants without running them.

Rails:

- `--rails` boots `config/environment` once, forks a process per mutant, sets `RAILS_ENV=test`, and runs 1 job at a time.
- `--rails --daemon --jobs 4` runs Minitest in parallel with a database per worker. SQLite only in 1.0.
- Mutineer itself needs Ruby 3.4. For an app on older Ruby, `--test-command "bundle exec rails test %{files}"` runs the suite in the app's Ruby. That mode runs serially and without coverage narrowing, so its score reads higher than an in-process score and is not comparable.

Equivalent mutants, the ones no test can kill because behavior does not change:

- Inline: `return 0 if items.empty? # mutineer:disable-line return_nil`.
- In `.mutineer.yml`: an `ignore:` list of survivor ids from the JSON report, each with a comment giving the reason.
- Suppressed mutants leave the score and appear under `ignored` in the JSON report.
- Mutineer's guide for agents says to flag a survivor for a person instead of looping. This skill sets the limit at 2 failed attempts.

Baselines for large codebases:

- On the main branch, save a full scan: `mutineer run lib --no-since --format json --output mutineer-baseline.json`.
- On a pull request, `--since origin/main --baseline mutineer-baseline.json` exits 1 on new survivors only. Keep a committed baseline outside the ignored `.mutineer/` folder.
- A pull request that changes only tests or docs has zero mutants and passes. The full scan on main is what catches a weakened suite.

## Skunk and RubyCritic

- Skunk reads `coverage/.resultset.json`. Run the tests with `COVERAGE=1` first, or every file reads 0% coverage.
- `skunk app lib` limits the report to those folders. `skunk -b main` compares the average score with main by switching branches, so commit or stash first.
- Score: RubyCritic's cost, multiplied by the uncovered percentage when coverage is under 100%. Churn is reported but not scored.
- Keep Skunk as a report, not a gate. A large, poorly covered file scores high even when a change does not touch it.
- `SHARE=true skunk` uploads the report to a public site. Never set it on private code.
- RubyCritic reads `.rubycritic.yml` (`paths`, `formats`, `no_browser`, `minimum_score`, `mode_ci`) and respects an existing Reek configuration. `rubycritic --format console --no-browser app lib` prints to the terminal.

## Mutation tools that failed

| Tool | Result on Ruby 4.0.3 |
|---|---|
| Mutant 0.16.3 | Reported every mutant alive, even one that replaced a method body with `raise`, on Ruby 4.0.3 and 3.3.5. Its parser gem reads Ruby 3.3 syntax only. |
| Evilution 1.1.0 | Ran no Minitest 6 tests: 46 of 47 mutants errored. |
| Hen'i-tai 0.5.3 | Works with `integration: minitest` in its configuration. It defaults to RSpec and samples 5% of mutants. |

## Sources

- Minitest `History.rdoc` in the installed 6.0.6 gem.
- The Changelog files in the installed rspec-core, rspec-mocks, and rspec-support gems, and the [rspec-rails changelog](https://github.com/rspec/rspec-rails/blob/main/Changelog.md).
- [SimpleCov README and configuration guide](https://github.com/simplecov-ruby/simplecov).
- [Mutineer README, changelog and guide for agents](https://github.com/davidteren/mutineer), and `lib/mutineer/config.rb`, `cli.rb`, and `test_runners/rspec.rb` in the installed 1.0.0 gem.
- [Skunk README](https://github.com/fastruby/skunk).
- [RubyCritic README](https://github.com/whitesmith/rubycritic).
