# Manual workflow

The checks `bin/verify-change` runs, one command at a time, so a person can run and read them without an agent. Open this when you run the checks one by one, or teach a person to run them. The Minitest outputs come from the refund change in the demo shop, and the RSpec outputs from a member discount change in a plain Ruby RSpec project. The base branch is `main` in every command.

## Contents

- Before you start
- Steps
- RSpec projects
- All steps in one command

## Before you start

- Run every command from the project root.
- Replace `main` with the base branch.
- Commit or `git add` new files first. `git diff` does not list untracked files, so no check would see them.

## Steps

1. List the changed Ruby files:

   ```sh
   git diff --name-only $(git merge-base main HEAD) -- '*.rb'
   ```

2. Remove old coverage, because SimpleCov merges recent runs, then run only the tests for those files with coverage on:

   ```sh
   rm -rf coverage
   COVERAGE=1 bundle exec ruby -Ilib -Itools -Itest -e 'ARGV.each { |f| require File.expand_path(f) }' test/refund_test.rb
   ```

   In a Rails app, run `COVERAGE=1 bin/rails test test/models/post_test.rb`. Add the integration or system tests of any feature the change touches.

   ```
   6 runs, 10 assertions, 0 failures, 0 errors, 0 skips
   Line coverage: 23 / 132 (17.42%)
   ```

   The whole-project coverage number is low because only one test file ran. Ignore it on a partial run; the next step measures the change.

3. Check that every changed line and branch ran:

   ```sh
   bundle exec simplecov patch --base main --minimum 100
   ```

   ```
   100.00% (13/13) lines  100.00% (12/12) branches  lib/refund.rb
   Patch coverage: 100.00% (13/13) lines, 100.00% (12/12) branches
   ```

   Below 100%, `bundle exec simplecov show lib/refund.rb --uncovered-only` lists the missed lines. In `coverage/index.html`, red lines never ran and yellow marks a branch that never ran.

4. Run mutation tests on the changed lines. The operators and the threshold come from `.mutineer.yml`:

   ```sh
   bundle exec mutineer run lib/refund.rb --test test/refund_test.rb --strategy redefine --since main
   ```

   In a Rails app, replace `--strategy redefine` with `--rails`.

   ```
   Total:        45      Killed:        45
   Survived:     0       No coverage:   0
   Mutation score: 100.0%
   PASSED: 100.0% >= threshold 75.0%
   ```

5. For each survivor, read the diff Mutineer prints, write a test that fails on that diff with an exact expected value, and run step 4 again. If 2 honest attempts cannot kill a survivor, decide whether the mutant changes any behavior at all. If it does not, it is equivalent: simplify the code or suppress it with `# mutineer:disable-line <operator>` and the reason.

6. Score the changed methods:

   ```sh
   bundle exec bin/crap --since main lib/refund.rb
   ```

   ```
   CRAP    complexity coverage  method
   4.0     4          100%      Refund#percent  lib/refund.rb:22
   3.0     3          100%      Refund#amount  lib/refund.rb:13
   3.0     3          100%      Refund#early_return_percent  lib/refund.rb:29
   2.0     2          100%      Refund#late_member_percent  lib/refund.rb:35
   4 methods, 0 above CRAP 30
   ```

   Above 30, add tests until the method is fully covered. If it is still above 30, split it into smaller named methods and go back to step 2.

7. Optional: see which files carry the most risk with `bundle exec skunk lib`. It needs the coverage from step 2.

8. Use the feature. Run the command, open the page, or repeat the steps of the bug that was fixed, and confirm the behavior by eye.

9. Push. CI runs the full suite. If CI is red, stop the release, fix the failure, and push again.

## RSpec projects

Only steps 2 and 4 change. Steps 3, 6, and 7 read the code and the coverage files, which look the same under RSpec.

| Step | Command |
|---|---|
| 2. Tests with coverage | `COVERAGE=1 bundle exec rspec spec/discount_spec.rb` |
| 4. Mutation tests | `bundle exec mutineer run lib/discount.rb --test spec/discount_spec.rb --framework rspec --strategy redefine --since main` |

A measured run: a branch added a member discount to `Discount#price` with this spec.

```ruby
it "charges a member less" do
  expect(described_class.new(member: true).price(50_00)).to be < 50_00
end
```

`bundle exec bin/verify-change main` passed the tests and patch coverage, then failed mutation testing and exited 1. The output, shortened:

```
Patch coverage: 100.00% (3/3) lines, 100.00% (2/2) branches

Total:        10      Killed:        6
Survived:     4       No coverage:   0
Mutation score: 60.0%
  Discount#price (discount.rb:11)
  Operator: literal_mutation  (100 -> 101)
  -     amount - amount * MEMBER_PERCENT / 100
  +     amount - amount * MEMBER_PERCENT / 101
FAILED: 60.0% < threshold 75.0%

Failed: Mutation testing
```

Exact expectations replaced the direction:

```ruby
it "takes 10 percent off for a member" do
  expect(described_class.new(member: true).price(50_00)).to eq(45_00)
end

it "rounds a member discount down to whole cents" do
  expect(described_class.new(member: true).price(1_99)).to eq(1_80)
end
```

The second run killed every mutant and exited 0:

```
Total:        10      Killed:        10
Survived:     0       No coverage:   0
Mutation score: 100.0%
PASSED: 100.0% >= threshold 75.0%

CRAP    complexity coverage  method
2.0     2          100%      Discount#price  lib/discount.rb:8
1 methods, 0 above CRAP 30

Change verified
```

## All steps in one command

`bundle exec bin/verify-change main` runs steps 2, 3, 4, and 6 and ends with `Change verified` or the names of the failed checks. On the demo refund change it took 1.91 seconds. Pass `--test FILE` for integration or system tests of a touched feature.
