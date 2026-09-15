# Isolation and scale

How to keep tests independent of each other, and how to speed up a slow suite without losing that independence. Open this when a test passes alone but fails with others, fails only under some seeds, leaves files or state behind, or when the suite is too slow.

## Contents

- Hermetic by construction
- Random order is a feature
- Parallel runs
- Sources

## Hermetic by construction

A test is hermetic when its result depends only on its own inputs, not on other tests, the run order, or global state.

- Keep per-test state in Minitest `setup` instance variables, or in RSpec `let` and local variables. Never use class variables (`@@count`), mutated top-level constants, or module-level caches: they leak across tests and across files.
- Do filesystem work in `Dir.mktmpdir`. The block form removes the folder even when the test fails. In setup and teardown style, create it in `setup` and call `FileUtils.remove_entry(@dir)` in `teardown`.

  ```ruby
  def test_writes_the_report
    Dir.mktmpdir do |dir|
      Tool.new(home: dir).run([])
      assert_path_exists File.join(dir, "report.txt")
    end
  end
  ```

- Wrap each test in a resource lifecycle with an `around` hook when many tests share a harness. RSpec has `around` built in. Minitest needs `minitest-around`, and version 0.6.0 ran green on Minitest 6.0.6 and Ruby 4.0.3:

  ```ruby
  require "minitest/around/unit"

  def around
    Dir.mktmpdir do |dir|
      @dir = dir
      yield
    end
  end
  ```

- Reset or inject singletons and memoized class-level collections that a test changes.

## Random order is a feature

Minitest runs tests in random order by default, and RSpec does once `spec_helper.rb` sets `config.order = :random`. A test that fails only in some orders has a real coupling bug, usually leaked state, not a flaky framework. Fix the leak; never pin the order.

| Need | Minitest 6 | RSpec 3.13 |
|---|---|---|
| Repeat a failing order | `--seed 1234` | `--seed 1234` |
| Find the test that leaks | `bundle exec minitest --bisect` | `bundle exec rspec --bisect` |

Minitest has no built-in rerun of the last failures: repeat the order with `--seed`, then find the leak with `--bisect`. RSpec reruns the last failures with `--only-failures` once `example_status_persistence_file_path` is set.

On two spec files where the first leaked a global, `rspec --bisect` printed the minimal reproduction:

```
The minimal reproduction command is:
  rspec './order/a_spec.rb[1:1]' './order/b_spec.rb[1:1]' --order defined
```

## Parallel runs

| Strategy | Isolation | Speed at 100+ files | Use |
|---|---|---|---|
| One process | Total, when tests are hermetic | Slowest, simplest | The default until it is too slow |
| Forked workers | Strong, separate memory | Scales with cores | The choice at scale |
| Threads | Weak: races on `$stdout`, class variables, caches, and C extensions | Limited by the GVL for plain Ruby | Only for thread-safe code |
| A process per file | Total | Slow, because Ruby boots per file | Avoid |

- Rails forks workers with `parallelize(workers: :number_of_processors)` and gives each worker its own test database. SimpleCov needs a `command_name` per worker, as the ruby-quality-checking skill's setup reference shows.
- In plain Ruby with Minitest, `minitest-parallel_fork` forks workers: `bundle exec ruby -rminitest/parallel_fork test/refund_test.rb`. Version 2.1.1 ran green on Minitest 6.0.6 and Ruby 4.0.3. Give each worker its own temporary folders and ports.
- `MT_CPU` sets the number of workers for Minitest's own parallel executor. `N` no longer does.
- RSpec 3.13 runs examples in one process. `parallel_tests` 5.8.0, `turbo_tests` 2.2.5, and `flatware` 2.4.0 all installed and ran green on Ruby 4.0.3, RSpec 3.13, Rails 8.1 (measured 2026-09-14). Recommend `parallel_tests`: it installs standalone with no resolver conflict and uses the `TEST_ENV_NUMBER` convention SimpleCov's own docs assume. `turbo_tests` requires `parallel_tests >= 3.3, < 5`, so it cannot sit in the same Gemfile as a standalone `parallel_tests 5.8.0`; pick one, or isolate with a second Gemfile. Add the `TEST_ENV_NUMBER` interpolation to `config/database.yml` first; a fresh Rails 8 app ships without it:

  ```yaml
  test:
    <<: *default
    database: storage/test<%= ENV["TEST_ENV_NUMBER"] %>.sqlite3
  ```

  Prepare worker databases with `RAILS_ENV=test bin/rails "parallel:create[N]"`, `RAILS_ENV=test bin/rails db:migrate`, then `RAILS_ENV=test bin/rails "parallel:load_schema[N]"`. `turbo_tests` numbers workers `1..N` and `flatware` numbers them `0..N-1` (not `parallel_tests`' `""`, `2..N`), so either needs its own worker-1 or worker-0 database created once. For SimpleCov to merge each worker's coverage, add `SimpleCov.command_name "rspec-#{ENV['TEST_ENV_NUMBER']}"` to `spec/spec_helper.rb`; the ruby-quality-checking skill's setup reference has the full block. `flatware` boots once in the parent before `TEST_ENV_NUMBER` is set per forked worker, so this interpolation resolves the same for every worker there, but SimpleCov's own `(subprocess: N)` disambiguation still merges the results correctly. At 80 examples with ~2s of real work, none of the three meaningfully beat plain `rspec`, because Rails boot time dominates a suite this small.
- A parallel run exposes coupling as well as saving time: tests that share state start to fail.

## Sources

- [Minitest parallelization and you](https://www.zenspider.com/ruby/2012/12/minitest-parallelization-and-you.html)
- [minitest-parallel_fork](https://github.com/jeremyevans/minitest-parallel_fork)
- [Rails parallel testing with forked processes](https://github.com/rails/rails/pull/31900)
- [minitest-around](https://github.com/splattael/minitest-around)
- [RSpec bisect](https://rspec.info/features/3-13/rspec-core/command-line/bisect/)
- [RSpec randomization](https://rspec.info/features/3-13/rspec-core/command-line/randomization/)
- [Prefer Dir.mktmpdir for temporary folders](https://makandracards.com/makandra/516356-prefer-using-dir-mktmpdir-when-dealing-with-temporary-directories-in-ruby)
- [Exploring Minitest concurrency](https://chriskottom.com/articles/exploring-minitest-concurrency/)
- [The perils of parallel testing in Ruby on Rails](https://blog.appsignal.com/2022/03/16/the-perils-of-parallel-testing-in-ruby-on-rails.html)
- [Flaky Minitest tests](https://mergify.com/learn/flaky-tests/minitest/)
