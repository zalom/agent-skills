# Test libraries

Facts about the test-writing libraries at the pinned versions, taken from each one's own README, changelog, and source, and from runs on Ruby 4.0.3. Open the section a question about options, versions, or upgrades names. The ruby-quality-checking skill covers SimpleCov, Mutineer, Skunk, RubyCritic, and rubocop-rspec.

## Contents

- Versions that work on Ruby 4.0
- Minitest 6
- RSpec 3.13
- Sources

## Versions that work on Ruby 4.0

| Gem | Pin | Measured | Note |
|---|---|---|---|
| minitest | `~> 6.0` | 6.0.6 | Rails 8.1.3 runs on it. |
| minitest-mock | `~> 5.27` | 5.27.0 | Holds `Minitest::Mock` and `stub` for Minitest 6. |
| minitest-around | `~> 0.6` | 0.6.0 | Ran green on Minitest 6.0.6. |
| minitest-parallel_fork | `~> 2.1` | 2.1.1 | Ran green on Minitest 6.0.6. |
| rspec | `~> 3.13` | 3.13.2 | rspec-core 3.13.6, rspec-expectations 3.13.5, rspec-mocks 3.13.8, rspec-support 3.13.7. Printed no Ruby warnings. |

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

## Sources

- Minitest `History.rdoc` in the installed 6.0.6 gem.
- The Changelog files in the installed rspec-core, rspec-mocks, and rspec-support gems, and the [rspec-rails changelog](https://github.com/rspec/rspec-rails/blob/main/Changelog.md).
