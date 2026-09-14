# Tool choices

Each of the 5 gates has a goal; the gem is the recommendation, not the requirement. Open this when picking a tool for a goal, or when a person asks why this skill recommends one gem over another.

## Contents

- The goal, then the tool
- Mutation tools that were tried and rejected
- How young a gem is Mutineer, and what to reach for instead
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
| henitai 0.5.3 | Superseded below: it is a working fallback on both frameworks, not rejected outright. |

## How young a gem is Mutineer, and what to reach for instead

Measured 2026-09-14 on Ruby 4.0.3:

- **Mutineer 1.0.0** released 2026-09-08. No open correctness bugs upstream as of the
  measurement date; open issues are docs, CI, and refactor work, plus one narrow
  pairing-convention gap (#87, source files whose tests were manually split across several
  `_test.rb` files lose convention-based pairing). Keep the `~> 1.0` pin.
- **henitai 0.5.3** is a working fallback on Minitest 6 and RSpec 3.13, Ruby 3.3.6 or later
  (it does not install on 3.3.5). It found the same 2 known survivors as Mutineer on the same
  fixture. Its RSpec integration needs `require "simplecov"` and `SimpleCov.start` written by
  hand in `spec/spec_helper.rb`, or the run stops with `Henitai::CoverageError` (its Minitest
  integration auto-requires that bootstrap; RSpec's does not). 18.5% of its runs needed a
  flaky retry in the measured sample. Run it with `bundle exec henitai run --operators full`
  (Minitest, auto-detected) or `--use rspec` for RSpec.
- **Evilution 1.1.0** is RSpec only. With Minitest, 5.27 or 6.0 alike, 47 of 48 mutants
  errored ("no Minitest tests executed") while it still reported `PASS 100%`, a broken
  integration that reads as a passing gate. Never use it with Minitest, on any Minitest
  version. With RSpec it ran cleanly: 48 mutants, 40 killed, 8 survived, 0 errored.
- **Mutant 0.16.3** reported every mutant alive on Ruby 4.0.3 and 3.3.5. It also refuses to
  run at all without a self-declared `--usage opensource` or `--usage commercial` flag (or a
  `usage:` config key), with no license key and no network check. `opensource` is contractually
  restricted to genuinely public open-source projects; anything private or commercial needs
  `commercial`, which requires payment.

## Sources

- [Mutineer README, changelog and guide for agents](https://github.com/davidteren/mutineer), and `lib/mutineer/config.rb`, `cli.rb`, and `test_runners/rspec.rb` in the installed 1.0.0 gem.
- [Skunk README](https://github.com/fastruby/skunk).
- [RubyCritic README](https://github.com/whitesmith/rubycritic).
