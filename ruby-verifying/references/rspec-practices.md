# RSpec practices

How to write, configure, and run RSpec specs in a project that already uses RSpec, and how the verification stack runs on them. Open this when writing or reviewing a spec, changing `spec_helper.rb` or `.rspec`, or choosing between Minitest and RSpec.

Every claim marked measured ran on Ruby 4.0.3 with rspec-core 3.13.6, rspec-expectations 3.13.5, rspec-mocks 3.13.8, and rspec-support 3.13.7.

## Contents

- Choosing Minitest or RSpec
- Versions on Ruby 4.0
- Project layout
- Configuration
- Writing examples
- let and let!
- Doubles
- Running specs
- RuboCop RSpec
- Coverage and mutation testing
- Sources

## Choosing Minitest or RSpec

- A new project, or a Rails app on the 37signals style, uses Minitest: it is plain Ruby, it ships with Rails, and every example in this skill starts there.
- A project that already has `spec/` with `.rspec`, or rspec in `Gemfile.lock`, keeps RSpec. Rewriting a working suite in another framework adds risk and checks nothing new.
- Never mix both frameworks in one project. `bin/verify-change` picks one per project.
- Every gate in this skill applies to both: patch coverage, Mutineer, and CRAP read the code, not the test framework.

## Versions on Ruby 4.0

| Gem | Pin | Measured | Note |
|---|---|---|---|
| rspec | `~> 3.13` | 3.13.2 | The whole suite ran with `config.warnings = true` and Ruby printed no warnings. |
| rspec-rails | `~> 8.0` | not run | Needs Rails 7.2 or later, from the [rspec-rails changelog](https://github.com/rspec/rspec-rails/blob/main/Changelog.md). |
| rubocop-rspec | `~> 3.10` | 3.10.2 | Ran with RuboCop 1.91.0. |

- This skill targets RSpec 3.13. When it was measured, `4.0.0.beta1` was the only 4.x release, a prerelease that drops the `should` syntax and the global DSL.
- A spec helper that follows this page already runs the way RSpec 4 will: without monkey patching and without `should`.

## Project layout

- `.rspec` holds `--require spec_helper`, so every spec file loads the helper without a `require` line.
- `spec/spec_helper.rb` configures RSpec and loads no application code, so a plain Ruby spec stays fast.
- In Rails, `rails generate rspec:install` also writes `spec/rails_helper.rb`, which requires `spec_helper`, boots the app, and loads `rspec/rails`. Specs that need Rails start with `require "rails_helper"`.
- RSpec puts `lib/` and `spec/` on the load path, so `require "discount"` finds `lib/discount.rb`.
- Name each spec after its source: `app/models/post.rb` in `spec/models/post_spec.rb`, `lib/shop/cart.rb` in `spec/shop/cart_spec.rb` or `spec/lib/shop/cart_spec.rb`. `bin/verify-change` finds specs by these names.

## Configuration

`rspec --init` writes most of this block commented out. Turn it on:

```ruby
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
```

- `disable_monkey_patching!` removes the top-level `describe` and the `should`, `stub`, and `should_receive` syntax. Measured: a top-level `describe` then fails with `undefined method 'describe' for main`. Without it, `1.should == 1` still runs and prints a deprecation warning.
- `verify_partial_doubles` makes `allow(real_object).to receive(:missing)` fail when the object has no such method. Measured.
- `example_status_persistence_file_path` enables `--only-failures`. Add `spec/examples.txt` to `.gitignore`.
- `config.order = :random` prints `Randomized with seed 23962`. RSpec never calls `Kernel.srand` itself, so the last line seeds Ruby's own randomness from the same seed.
- `config.warnings = true` shows Ruby warnings. Turn it on to audit an upgrade, and off when gems flood the output.

## Writing examples

From the RSpec style guide:

- Describe a class with `RSpec.describe Discount`, an instance method with `describe "#price"`, and a class method with `describe ".build"`.
- Start `context` descriptions with "when", "with", or "without". An example description that ends in a condition belongs in a `context`.
- Refer to the class under test as `described_class`.
- Write `expect(value).to eq(expected)`. Never write `should`.
- Test one behavior per example. When one behavior needs several expectations, tag the example `:aggregate_failures`, and RSpec reports every failed expectation, not only the first. Measured: `Got 2 failures`.
- Keep each example flat and short: build inputs, act once, check the result.

Examples that kill mutants follow the same rules as Minitest tests:

```ruby
RSpec.describe Discount do
  describe "#price" do
    context "with a member" do
      it "takes 10 percent off" do
        expect(described_class.new(member: true).price(50_00)).to eq(45_00)
      end
    end

    context "without a member" do
      it "charges the full price" do
        expect(described_class.new(member: false).price(50_00)).to eq(50_00)
      end
    end
  end
end
```

`expect(price).to be < 50_00` would pass with `/ 101` in place of `/ 100`. The exact `eq(45_00)` fails on that mutant.

## let and let!

- `let(:order) { Order.new }` is lazy: the block runs the first time an example calls `order`, and the value is memoized for that example only.
- `let!(:order)` is eager: it defines a `before` hook, so the block runs before every example in the group, whether the example uses it or not.
- Measured: with both declared, the `let!` value existed when the example started, and calling the `let` twice ran its block once.
- Use `let` by default. Use `let!` only when the example depends on the side effect, such as a database row a query must find. RuboCop RSpec's `RSpec/LetSetup` flags a `let!` that no example references.
- Never use instance variables in `before` blocks to share state; use `let`.

## Doubles

- Prefer real objects passed in through the constructor, as `testable-design.md` shows. Reach for a double at a boundary.
- Use verifying doubles: `instance_double(Mailer)`, `class_double(Mailer)`, and `object_double(mailer)`. They check the stubbed methods against the real class.
  - Measured: `allow(instance_double(Mailer)).to receive(:send_now)` raised `the Mailer class does not implement the instance method: send_now`.
  - Measured: calling a stubbed `deliver(to)` with 2 arguments raised `Wrong number of arguments`.
- Plain `double("Mailer")` checks nothing, so a renamed method still passes. RuboCop RSpec's `RSpec/VerifiedDoubles` flags it.
- Check a call after the fact with a spy: `allow(mailer).to receive(:deliver)`, act, then `expect(mailer).to have_received(:deliver).with("a@example.com")`.
- Avoid `allow_any_instance_of` and `expect_any_instance_of`. They hide a missing injection point.

## Running specs

| Command | What it does |
|---|---|
| `bundle exec rspec spec/discount_spec.rb:9` | Runs the example on that line. |
| `bundle exec rspec --only-failures` | Runs the examples that failed last time. Without `example_status_persistence_file_path`, it stops with a message that asks for it. Measured. |
| `bundle exec rspec --next-failure` | The same as `--only-failures --fail-fast --order defined`: fix one failure at a time. |
| `bundle exec rspec --bisect` | Finds the smallest set of examples that reproduces an order-dependent failure. Measured. |
| `bundle exec rspec --profile 10` | Lists the 10 slowest examples and groups. Measured. |
| `bundle exec rspec --seed 1234` | Repeats a random order. |

## RuboCop RSpec

Add the gem, then load it as a plugin in `.rubocop.yml`, which needs RuboCop 1.72 or later:

```yaml
plugins:
  - rubocop-rspec
```

Measured on one spec with common problems, `rubocop --only RSpec` reported these cops:

| Cop | Flags |
|---|---|
| `RSpec/LetSetup` | A `let!` that no example references. |
| `RSpec/VerifiedDoubles` | A plain `double`. |
| `RSpec/InstanceVariable` | `@mailer` shared from a `before` block. |
| `RSpec/AnyInstance` | `allow_any_instance_of`. |
| `RSpec/MessageSpies` | `expect(...).to receive` set up before acting, where the configured style is `have_received`. |
| `RSpec/MultipleExpectations` | More than 1 expectation in an example. Tag it `:aggregate_failures` or split it. |
| `RSpec/DescribedClass` | The class name where `described_class` fits. |
| `RSpec/SpecFilePathFormat` | A spec file whose path does not match the described class. |

## Coverage and mutation testing

- `scripts/setup-project` treats a project with `spec/` and `.rspec`, or with `rspec`, `rspec-core`, or `rspec-rails` under `DEPENDENCIES` in `Gemfile.lock`, as an RSpec project, and stops with exit 4 in a Rails app that has neither spec helper. It adds the coverage block to the top of `spec/spec_helper.rb`, or of `spec/rails_helper.rb` when that is the only helper, writes `framework: rspec` to `.mutineer.yml`, adds no minitest gem, and leaves every `require` line alone.
- `bin/verify-change` runs `bundle exec rspec` on the specs it maps from the changed files, then `mutineer run ... --framework rspec`.
- Mutineer 1.0.0 runs RSpec in its default forked mode. `--daemon` supports Minitest only and exits 2 with RSpec.
- Measured end to end on a plain Ruby project: see "RSpec projects" in `manual-workflow.md`.
- A Rails RSpec app gets `--rails` from `bin/verify-change`. That combination has unit tests but no end-to-end run yet.

## Sources

- The Changelog files in the installed rspec-core 3.13.6, rspec-mocks 3.13.8, and rspec-support 3.13.7 gems.
- [RSpec style guide](https://rspec.rubystyle.guide/)
- [RuboCop RSpec installation](https://docs.rubocop.org/rubocop-rspec/latest/installation.html) and [cops](https://docs.rubocop.org/rubocop-rspec/latest/cops_rspec.html)
- [Verifying doubles](https://rspec.info/features/3-13/rspec-mocks/verifying-doubles/)
- [Aggregating failures](https://rspec.info/features/3-13/rspec-expectations/aggregating-failures/)
- [Only failures](https://rspec.info/features/3-13/rspec-core/command-line/only-failures/)
- [Bisect](https://rspec.info/features/3-13/rspec-core/command-line/bisect/)
- [Profile examples](https://rspec.info/features/3-13/rspec-core/configuration/profile/)
- [Randomization](https://rspec.info/features/3-13/rspec-core/command-line/randomization/) and [order](https://rspec.info/features/3-13/rspec-core/command-line/order/)
- [Zero monkey patching mode](https://rspec.info/features/3-13/rspec-core/configuration/zero-monkey-patching-mode/)
- [rspec-rails changelog](https://github.com/rspec/rspec-rails/blob/main/Changelog.md) and [README](https://github.com/rspec/rspec-rails)
- [The spec_helper that rspec --init writes](https://github.com/rspec/rspec-core/blob/main/lib/rspec/core/project_initializer/spec/spec_helper.rb)
