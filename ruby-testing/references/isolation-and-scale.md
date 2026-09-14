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
- RSpec 3.13 runs examples in one process. No RSpec parallel runner was tested on Ruby 4.0 for this skill; `parallel_tests` and `turbo_tests` exist.
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
