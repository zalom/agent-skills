# Minitest idioms

How to write Minitest 6 tests that read well and kill mutants. Open this when writing or reviewing a Minitest test, or when a Minitest 5 suite breaks after an upgrade.

## Contents

- Setup
- Two styles
- Assertions
- Setup and teardown
- Stubs and mocks
- Fixtures over factories
- Running tests
- Sources

## Setup

- Minitest is a bundled gem in Ruby, so a Bundler project lists it: `gem "minitest", "~> 6.0"`. A Rails app gets it through Rails.
- Plugins load only when required. Require each plugin in the test helper, or call `Minitest.load_plugins`.
- The `MiniTest` alias is gone. Write `Minitest`.

## Two styles

Unit style is the default here, in Rails, and at 37signals:

```ruby
require "minitest/autorun"

class CalculatorTest < Minitest::Test
  def setup
    @calculator = Calculator.new
  end

  def test_adds_two_numbers
    assert_equal 4, @calculator.add(2, 2)
  end
end
```

Spec style runs on the same engine. Minitest 6 removed expectations from `Object`, so wrap the value in `_()`:

```ruby
describe Calculator do
  it "adds two numbers" do
    _(Calculator.new.add(2, 2)).must_equal 4
  end
end
```

## Assertions

- Put the expected value first: `assert_equal expected, actual`. Reversed arguments print a misleading message.
- Use the most specific assertion for a clearer failure message:
  - `assert_nil value` and `refute_nil value`
  - `assert_empty collection` and `refute_empty collection`
  - `assert_includes collection, item`
  - `assert_predicate order, :paid?`
  - `assert_raises(ArgumentError) { parse("") }`
  - `assert_match(/\A\d+\z/, code)`
  - `assert_same` for identity, `assert_equal` for value
- Write `assert_nil value`, never `assert_equal nil, value`. Minitest 6 fails the second form with `Use assert_nil if expecting nil.` Since 6.0.3, `assert_same nil, value` fails too.
- `assert_send` is gone. Use `assert_predicate` or `assert_operator`.
- Avoid `assert some_boolean`. Its failure reads `Expected false to be truthy`, which names nothing.

Assertions that kill mutants:

- Assert the exact value: `assert_equal 49_90, order.total`. A direction such as `assert_operator order.total, :<, 54_90` lets a changed constant pass.
- Test both sides of every boundary: `100_00` gets free shipping, `99_99` does not.
- Assert the result of each branch, including the `else`.

## Setup and teardown

- `setup` runs before each test method, and `teardown` runs after each one, even on failure.
- Assign per-test state to instance variables in `setup`. Each test runs in a fresh instance, which is the basis of isolation.
- Never keep per-test state in class variables or mutated top-level constants.

## Stubs and mocks

Minitest 6 moved `Minitest::Mock` and `Object#stub` to the `minitest-mock` gem. Without that gem, neither is defined. Add `gem "minitest-mock", "~> 5.27"` and require it:

```ruby
require "minitest/mock"

def test_reports_the_epoch
  Time.stub(:now, Time.at(0)) do
    assert_equal 0, Time.now.to_i
  end
end

def test_warns_when_the_disk_runs_low
  logger = Minitest::Mock.new
  logger.expect(:warn, nil, ["disk low"])
  DiskMonitor.new(logger: logger).check(free_percent: 5)
  assert_mock logger
end
```

Stub only at true boundaries: the clock, randomness, the network, and external IO. For internal collaborators, pass real objects through dependency injection, as `testable-design.md` shows. A mock couples the test to the calls the code makes.

## Fixtures over factories

Static fixtures load fast and are explicit. Factories add indirection and runtime cost. In a plain Ruby project, use plain data, fixture files, or small builder methods in the test.

## Running tests

- `bundle exec minitest test/refund_test.rb:13` runs the test on that line.
- `bundle exec minitest --bisect` finds the test that makes another one fail when they run in order.
- `--seed 1234` repeats an order. `--name` still filters tests, but `--include` replaces it.
- `MT_CPU` sets the number of parallel workers. `N` no longer does.

## Sources

- Minitest `History.rdoc` in the installed 6.0.6 gem.
- [Minitest documentation](http://docs.seattlerb.org/minitest/)
- [Minitest style guide](https://github.com/rubocop/minitest-style-guide)
- [minitest-mock](https://rubygems.org/gems/minitest-mock)
- [Practical metaprogramming in Minitest::Mock](https://wasabigeek.com/blog/practical-metaprogramming-in-ruby-minitest-mock/)
