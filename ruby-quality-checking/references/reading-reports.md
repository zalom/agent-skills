# Reading reports

What each line of each tool's output means. Open the section for the tool whose output is on screen.

## Contents

- bin/verify-change
- Minitest
- RSpec
- SimpleCov
- Mutineer
- bin/crap
- Skunk

## bin/verify-change

- `Base`, `Sources`, and `Tests` show what it compared and which tests it chose.
- Each `== Title` line starts a check: Tests with coverage, Patch coverage, Mutation testing, CRAP scores.
- The last line is `Change verified`, or `Failed:` with the names of the failed checks.
- `No test file found for:` means a changed source file has no matching test or spec file and the change touched none. Write the test, or pass `--test FILE`.
- `Not checked, because git does not track them yet` lists new files to `git add`.
- `Both test/ and spec/ exist` means the project has both folders, and only the tests of the named framework run.

## Minitest

- Each `.` is a passing test, `F` a failure, `E` an error, and `S` a skip.
- `6 runs, 10 assertions, 0 failures, 0 errors, 0 skips` is the summary. Anything other than 0 failures and 0 errors is a failed change.

## RSpec

- Each `.` is a passing example, `F` a failure, and `*` a pending example.
- `3 examples, 0 failures` is the summary. Any failure is a failed change.
- `Randomized with seed 6364` names the order. Repeat a failure in the same order with `--seed 6364`.
- Under `Failed examples:`, each `rspec ./spec/discount_spec.rb:9` line is a command that reruns that example.

## SimpleCov

- After a test run, `Line coverage` and `Branch coverage` cover the whole project. On a partial run they are low by design.
- `simplecov patch` prints one row per changed file, then `Patch coverage` for the change. Only this number is a gate.
- In `coverage/index.html`, green lines ran, red lines never ran, and a yellow mark is a branch that never ran.
- Skunk reads `coverage/.resultset.json`, and the `simplecov` commands read `coverage/coverage.json`. Both files come from a run with `COVERAGE=1`.

## Mutineer

The summary block:

```
Total:        72      Killed:        46
Survived:     17      No coverage:   9
Skipped:      0       Errored:       0
Uncapturable: 0       (tests failed to run)
Ignored:      0       (equivalent, suppressed)

Mutation score: 73.0%  (killed / (killed + survived); 9 no-coverage, 0 uncapturable, 0 skipped, 0 errored, 0 ignored excluded)
```

- The score counts only killed and survived mutants.
- With a threshold, a final line such as `PASSED: 100.0% >= threshold 75.0%` states the result, and the exit code is 1 when it fails.

Each survivor names the file, the method and line, the operator with the change it made, and the diff:

```
lib/checkout.rb
  Checkout#total (checkout.rb:14)
  Operator: literal_mutation  (100 -> 101)
  -     subtotal -= subtotal * MEMBER_DISCOUNT_PERCENT / 100 if @member
  +     subtotal -= subtotal * MEMBER_DISCOUNT_PERCENT / 101 if @member
```

- `[mutineer] 45/45 mutants (100%)` lines are progress on stderr.
- "already initialized constant" warnings come from loading mutated code. They do not change the results.
- With `--format json`, the `summary` object holds the counts and `survivors` holds `id`, `subject`, `file`, `line`, `operator`, `token`, and `diff` for each survivor.

## bin/crap

- One row per method, worst first: the CRAP score, the complexity, the method's line coverage, the method name, and its file and line.
- The last line counts the methods above the threshold. The command exits 1 when any method is above it, and 2 on an unknown option or a `--threshold`, `--since`, or `--coverage` flag with no value.
- With `--since REF`, it scores only the methods whose lines changed.
- Without `coverage/.resultset.json`, every method reads 0% coverage.

## Skunk

- One row per file: `skunk_score`, `churn_times_cost`, `churn` (commits that touched the file), `cost` (RubyCritic's complexity and smell cost), and `coverage`.
- The rows are sorted worst first, followed by the total, the average, and the worst file.
- A file at 0% coverage often means no coverage file was found, not that the file is untested.
