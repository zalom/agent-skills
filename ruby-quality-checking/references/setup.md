# Setup

What `scripts/setup-project` changes in a project, and the same steps by hand for a person working without an agent. The files it copies live in this skill's `assets/` folder. Open this when the script warns, keeps a file you expected it to change, or a person sets up the stack by hand.

## Contents

- Requirements
- The script
- By hand in a plain Ruby project with Minitest
- By hand in a Rails app with Minitest
- RSpec: coverage and mutation testing
- By hand in an RSpec project
- Skunk report (optional)
- Ruby older than 3.4

## Requirements

- Ruby 3.4 or later for Mutineer. Every result in this skill was measured on Ruby 4.0.3.
- A Minitest or RSpec suite. Rails apps use Minitest by default.
- A git repository with a base branch, because every check compares against it.
- An existing `gem "simplecov"` pin below 1.3 must be raised: the `skip`/`cover` coverage DSL
  the `coverage/` assets use needs SimpleCov 1.0 or later, and raises `NoMethodError` on 0.22.0.

## The script

```sh
ruby path/to/ruby-quality-checking/scripts/setup-project --dry-run path/to/project
ruby path/to/ruby-quality-checking/scripts/setup-project path/to/project
cd path/to/project
bundle install
```

The dry run prints each file as `would be created` or `would be updated`. The real run prints `created`, `updated`, or `kept`, and a second run prints only `kept`. `--no-ci` skips the workflow.

The script reads the project's files to decide what kind of project it is:

| It finds | It treats the project as |
|---|---|
| `config/application.rb` | A Rails app |
| `spec/` with `.rspec`, `spec/spec_helper.rb`, or `spec/rails_helper.rb`, or `rspec`, `rspec-core`, or `rspec-rails` under `DEPENDENCIES` in `Gemfile.lock` | An RSpec project |

A direct `rspec-expectations` or `rspec-mocks` dependency, or rspec listed only as another gem's dependency, does not make a project an RSpec project. When both `test/` and `spec/` exist, the script warns that it sets up only one of them, and `bin/verify-change` warns that it runs only one.

In an RSpec project, the script:

- Adds the coverage block to the top of `spec/spec_helper.rb`, or of `spec/rails_helper.rb` when that is the only helper. A plain Ruby project without either helper gets a new `spec/spec_helper.rb`. A Rails app without either helper stops with exit 4 and changes nothing: run `bin/rails generate rspec:install` first.

A Rails app that uses Minitest and has no `test/test_helper.rb` stops with exit 5 and changes nothing: set up the Rails test directory first, then run the script again.
- Creates `.rspec` with `--require spec_helper` when it is missing.
- Writes `framework: rspec` into a new `.mutineer.yml`.
- Copies `spec/tools/crap_spec.rb` in place of `test/tools/crap_test.rb`.
- Adds no minitest gem and no `Rakefile`, and changes no `require` line.
- Adds `spec/examples.txt` to `.gitignore`.
- Writes `COVERAGE=1 bundle exec rspec` as the suite command in CI.

After the script, run the whole suite once with coverage and commit:

```sh
COVERAGE=1 bundle exec rake test
git add -A
git commit -m "Add the verification stack"
```

Replace the first command with `COVERAGE=1 bin/rails test` in a Rails app with Minitest, or with `COVERAGE=1 bundle exec rspec` in an RSpec project.

## By hand in a plain Ruby project with Minitest

1. Add the tools to the `Gemfile`:

   ```ruby
   group :development, :test do
     gem "minitest", "~> 6.0", require: false
     gem "simplecov", "~> 1.3", require: false
     gem "mutineer", "~> 1.0", require: false
   end
   ```

   `bin/crap`'s CRAP gate needs only `prism`, which ships as a default gem on Ruby 3.3 and
   later; add `gem "prism", "~> 1.0", require: false` only on an older Ruby. Skunk, RubyCritic,
   and Flog are a separate, optional report: see "Skunk report (optional)" below.

2. Run `bundle install`.
3. Put the block from `assets/coverage/plain.rb` at the very top of `test/test_helper.rb`:

   ```ruby
   if ENV["COVERAGE"]
     require "simplecov"
     SimpleCov.start do
       enable_coverage :branch
       skip "/test/"
       cover "{app,lib,tools}/**/*.rb"
     end
   end
   ```

4. In every test file, replace `require "test_helper"` with `require_relative "test_helper"`, or `require_relative "../test_helper"` one folder deeper. Mutineer loads each test file in its own process, where a plain `require` cannot find the helper.
5. Copy `assets/mutineer.yml` to `.mutineer.yml` in the project root.
6. Copy `assets/bin/crap`, `assets/bin/verify-change`, `assets/tools/crap.rb`, and `assets/test/tools/crap_test.rb` to the same paths in the project, then run `chmod +x bin/crap bin/verify-change`.
7. If the project has no `Rakefile`, copy `assets/Rakefile`.
8. Add `coverage/` and `.mutineer/` to `.gitignore`.
9. Add a CI workflow. `ci.md` describes the two jobs.
10. Check the setup:

    ```sh
    COVERAGE=1 bundle exec rake test
    open coverage/index.html
    bundle exec bin/crap
    bundle exec mutineer run lib/shop.rb --test test/shop_test.rb --strategy redefine
    ```

## By hand in a Rails app with Minitest

1. Add the same `Gemfile` group without the `minitest` line. Rails already depends on Minitest.
2. Run `bundle install`.
3. Put the block from `assets/coverage/rails.rb` at the very top of `test/test_helper.rb`, before Rails loads:

   ```ruby
   if ENV["COVERAGE"]
     require "simplecov"
     SimpleCov.start "rails" do
       enable_coverage :branch
       cover "{app,lib,tools}/**/*.rb"
     end
   end
   ```

4. Directly below the `parallelize(workers: :number_of_processors)` line, give each worker its own coverage name so the results merge:

   ```ruby
   if ENV["COVERAGE"]
     parallelize_setup { |worker| SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}" }
     parallelize_teardown { |_worker| SimpleCov.result }
   end
   ```

5. Copy `.mutineer.yml`, `bin/crap`, `bin/verify-change`, `tools/crap.rb`, and `test/tools/crap_test.rb` as in a plain project. Rails test files keep `require "test_helper"`; Mutineer's Rails mode finds it.
6. Add `coverage/` and `.mutineer/` to `.gitignore`.
7. Add the verify job to CI with `bin/rails db:test:prepare` before it. `ci.md` has the details.
8. Check the setup:

   ```sh
   COVERAGE=1 bin/rails test
   bundle exec mutineer run app/models/post.rb --test test/models/post_test.rb --rails
   ```

## RSpec: coverage and mutation testing

- `scripts/setup-project` treats a project with `spec/` and `.rspec`, `spec/spec_helper.rb`, or `spec/rails_helper.rb`, or with `rspec`, `rspec-core`, or `rspec-rails` under `DEPENDENCIES` in `Gemfile.lock`, as an RSpec project, and stops with exit 4 in a Rails app that has neither spec helper. It adds the coverage block to the top of `spec/spec_helper.rb`, or of `spec/rails_helper.rb` when that is the only helper, writes `framework: rspec` to `.mutineer.yml`, adds no minitest gem, and leaves every `require` line alone.
- `bin/verify-change` runs `bundle exec rspec` on the specs it maps from the changed files, then `mutineer run ... --framework rspec`.
- Mutineer 1.0.0 runs RSpec in its default forked mode. `--daemon` supports Minitest only and exits 2 with RSpec.
- Measured end to end on a plain Ruby project: see "RSpec projects" in `manual-workflow.md`.
- A Rails RSpec app gets `--rails` from `bin/verify-change`. That combination has unit tests but no end-to-end run yet.

## By hand in an RSpec project

1. Add the `Gemfile` group without the `minitest` line.
2. Run `bundle install`.
3. Put a coverage block at the very top of `spec/spec_helper.rb`: `assets/coverage/rspec.rb` in plain Ruby, which skips `/spec/`, or `assets/coverage/rails.rb` in a Rails app. `.rspec` loads `spec_helper` first, so coverage starts before any application code.

   ```ruby
   if ENV["COVERAGE"]
     require "simplecov"
     SimpleCov.start do
       enable_coverage :branch
       skip "/spec/"
       cover "{app,lib,tools}/**/*.rb"
     end
   end
   ```

4. Check that `.rspec` holds `--require spec_helper`. Leave every `require "spec_helper"` and `require "rails_helper"` line as it is: RSpec puts `spec/` on the load path, and Mutineer runs specs through RSpec.
5. Copy `assets/mutineer.yml` to `.mutineer.yml` and add the line `framework: rspec`.
6. Copy `assets/bin/crap`, `assets/bin/verify-change`, `assets/tools/crap.rb`, and `assets/spec/tools/crap_spec.rb` to the same paths in the project, then run `chmod +x bin/crap bin/verify-change`.
7. Add `coverage/`, `.mutineer/`, and `spec/examples.txt` to `.gitignore`.
8. Add a CI workflow with `COVERAGE=1 bundle exec rspec` as the suite command, and `bin/rails db:test:prepare` first in a Rails app.
9. Check the setup:

   ```sh
   COVERAGE=1 bundle exec rspec
   bundle exec bin/crap
   bundle exec mutineer run lib/discount.rb --test spec/discount_spec.rb --framework rspec --strategy redefine
   ```

   In a Rails app, replace `--strategy redefine` with `--rails`. Never add `--daemon` to an RSpec run: Mutineer 1.0 runs the daemon with Minitest only.

## Skunk report (optional)

Skunk, RubyCritic, and Flog are a risk report across the codebase, not part of the default
setup: `setup-project` no longer adds them. Add them by hand when a team wants the report
(`team-adoption.md` step 2):

```ruby
group :development, :test do
  gem "skunk", "~> 0.5", require: false
  gem "rubycritic", "~> 4.12", require: false
  gem "flog", "~> 4.9", require: false
  gem "ostruct", "~> 0.6", require: false
end
```

Pin RubyCritic to `~> 4.12`: Skunk 0.5.4 hard-caps RubyCritic below 5.0
(`skunk.gemspec` still reads `"< 5.0"`; the one pull request to lift the floor, #132, bumped it
to 4.11 and was closed unmerged as a compatibility break, with no other open work toward
RubyCritic 5). Add `ostruct` on Ruby 4.0, because RubyCritic needs it and Ruby 4.0 only loads
a gem Bundler doesn't otherwise pull in when the Gemfile lists it. Never set `SHARE=true`: it
uploads the report to a public site.

## Ruby older than 3.4

Mutineer runs on Ruby 3.4 or later. For a project on Ruby 3.3 or older, either upgrade the project, or install Mutineer under a newer Ruby and run the project's tests in the project's own Ruby:

```sh
RAILS_ENV=test mutineer run app/models/post.rb --test test/models/post_test.rb \
  --test-command "bundle exec rails test %{files}"
```

That mode runs every `--test` file for every mutant (no per-mutant coverage narrowing) and
ignores `--jobs`: Mutineer prints that it forces 1. Its score is an upper bound, not
comparable to an in-process run, because an infrastructure failure in the child scores as a
kill same as a real one. Mutant counts matched a native run of the same project on Ruby
3.4.4 (6 mutants, 5 killed, 83.3%, Mutineer 1.0.0). The score is still an upper bound.
`bin/verify-change` does not use it.

Under mise, a naive `--test-command` fails with `RubyVersionMismatch`: Mutineer 1.0.0's own
PATH-scrubbing only recognizes rbenv and asdf's version-manager layout, not mise's
`~/.local/share/mise/installs/ruby/<version>/bin`. A wrapper script fixes it:

```sh
#!/bin/bash
export PATH="$(mise where ruby@3.3.5)/bin:$PATH"
exec bundle exec ruby -Ilib -Itest "$@"
```

Pass it as `--test-command "./run_tests.sh %{files}"`. This is a reference recipe, not an
asset the script copies; write it into the project by hand.

henitai 0.5.3 declares Ruby 3.3.6 or later; it was measured only on Ruby 4.0.3 and never run
on 3.3.x. See `tool-choices.md`.
