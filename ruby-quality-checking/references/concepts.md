# The checks

Plain definitions, the formulas, and a worked example for each check, all taken from the demo shop in the Ruby verification stack demo repository. Open this when a person asks what a report means or why a check exists.

## Unit tests and coverage

- A unit test calls one piece of code and checks the result. Minitest or RSpec runs them.
- Coverage is the share of lines, and of branches, that ran during the tests. SimpleCov measures it.
- Coverage proves that code ran. It does not prove that anything checked the result.

In the demo, weak checkout tests covered 95.7% of the lines in `checkout.rb` (22 of 23) and every test passed.

## Mutation tests

A mutation tool changes the code one small step at a time, runs the tests against each change, and puts the code back. Each changed copy is a mutant.

| Status | Meaning | Action |
|---|---|---|
| Killed | A test failed on the mutant. | None. |
| Survived | Every test still passed. The line runs but nothing checks it. | Write a test that fails on the mutant's diff. |
| No coverage | No test runs that line. | Write a test that reaches it. |
| Uncapturable | The tests could not run at all. | Fix the load path, usually `require_relative "test_helper"` in plain Ruby with Minitest. |
| Errored or timeout | The run broke, not the tests. | Rerun with `--verbose`. |
| Ignored | Suppressed as an equivalent mutant. | Keep the reason next to the suppression. |

Mutation score = killed / (killed + survived). Mutants with no coverage, no verdict, or a suppression stay out of the score.

The demo checkout with its weak tests produced 72 mutants: 46 killed, 17 survived, and 9 with no coverage, so the score was 46 / 63 = 73.0%.

One survivor changed the member discount:

```diff
- subtotal -= subtotal * MEMBER_DISCOUNT_PERCENT / 100 if @member
+ subtotal -= subtotal * MEMBER_DISCOUNT_PERCENT / 101 if @member
```

The old test asserted a direction:

```ruby
assert_operator checkout.total, :<, 54_90
```

With `/ 101` a member pays 49.95 instead of 49.90, which is still less than 54.90, so the test passed. An exact assertion fails on the mutant and kills it:

```ruby
assert_equal 45_00 + 4_90, checkout(price: 50_00, member: true).total
```

After the checkout tests asserted exact amounts and both sides of every boundary, all 72 mutants were killed.

## CRAP

CRAP (Change Risk Anti-Patterns) gives each method one score from its complexity and its coverage, with coverage as a number from 0 to 1:

```
CRAP = complexity² × (1 − coverage)³ + complexity
```

Complexity is 1, plus 1 for each `if`, `elsif`, ternary, `unless`, `while`, `until`, `for`, `when`, `in`, `rescue`, `&&`, `||`, `&.`, `||=`, and `&&=`. The limit is 30.

| Complexity | Coverage | CRAP |
|---|---|---|
| 10 | 0% | 110 |
| 10 | 100% | 10 |
| 7 | 0% | 56 |
| 6 | 50% | 10.5 |
| 4 | 100% | 4 |
| 31 | 100% | 31 |

- Tests lower the score of a complex method. Full coverage leaves only the complexity.
- A method with complexity above 30 stays above the limit at full coverage. Split it.

In the demo, the untested `Refund#amount` had complexity 10 and scored 110. Boundary tests brought it to 10. Splitting it into small named methods brought the worst method to 4.

## Skunk

Skunk scores whole files. The score is RubyCritic's cost (complexity and code smells), multiplied by the uncovered percentage when coverage is under 100%. In the demo, `refund.rb` went from 99.56 to 0.82 after the tests and the split. Skunk ranks where debt sits across a codebase; it is a report, not a gate.

## How the checks work together

| Check | Catches | Misses |
|---|---|---|
| Tests with coverage | Code that never runs | Code that runs but is never checked |
| Patch coverage | Changed lines no test reaches | Weak assertions on those lines |
| Mutation tests | Behavior the tests do not check | Code that is correct but too complex to change safely |
| CRAP | Complex methods with little coverage | Weak assertions on covered code |
| Skunk | Risky files across the codebase | Anything about one particular change |
