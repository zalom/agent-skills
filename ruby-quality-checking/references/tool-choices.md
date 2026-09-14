# Tool choices

Each of the 5 gates has a goal; the gem is the recommendation, not the requirement. Open this when picking a tool for a goal, or when a person asks why this skill recommends one gem over another.

## Contents

- The goal, then the tool
- Mutation tools that were tried and rejected
- Sources

## The goal, then the tool

| Goal | Recommended tool | Alternative | Known limit |
|---|---|---|---|
| Lint in the project's style | The project's own: rubocop-rails-omakase, standard, or rubocop | - | Two style guides at once reads as ambiguous; this skill never picks one for you. |
| Patch coverage on changed lines | SimpleCov 1.3, `simplecov patch` | - | Merges recent runs; remove `coverage/` before a partial run. |
| Mutation score on changed lines | Mutineer 1.0 | See rejected tools below | Needs Ruby 3.4 or later. |
| CRAP score per changed method | `bin/crap`, this skill's own script | RubyCritic's cost metric, unscored | Reads `coverage/.resultset.json`; without it every method reads 0% coverage. |
| Risk across a codebase (a report, not a gate) | Skunk plus RubyCritic | - | Skunk pins RubyCritic to `~> 4.12`. |

## Mutation tools that were tried and rejected

| Tool | Result on Ruby 4.0.3 |
|---|---|
| Mutant 0.16.3 | Reported every mutant alive, even one that replaced a method body with `raise`, on Ruby 4.0.3 and 3.3.5. Its parser gem reads Ruby 3.3 syntax only. |
| Evilution 1.1.0 | Ran no Minitest 6 tests: 46 of 47 mutants errored. |
| Hen'i-tai 0.5.3 | Works with `integration: minitest` in its configuration. It defaults to RSpec and samples 5% of mutants. |

## Sources

- [Mutineer README, changelog and guide for agents](https://github.com/davidteren/mutineer), and `lib/mutineer/config.rb`, `cli.rb`, and `test_runners/rspec.rb` in the installed 1.0.0 gem.
- [Skunk README](https://github.com/fastruby/skunk).
- [RubyCritic README](https://github.com/whitesmith/rubycritic).
