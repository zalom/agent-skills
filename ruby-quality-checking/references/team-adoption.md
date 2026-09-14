# Team adoption

The case for the stack, a rollout order for an existing codebase, and the limits to state up front. Open this when proposing the stack to a team or adding it to a large, older codebase.

## The case

- It catches what coverage hides. In the demo, tests with 95.7% line coverage let 17 of 72 mutants survive. In a Ruby command line tool with 4,738 tests, one real change had 2 test gaps that its 31 green tests missed.
- It checks the change, not the codebase. The tests for that one change took 0.31 seconds, where the full suite took 7.3 minutes on a laptop.
- It ranks risk. CRAP put an untested method with 10 paths at 110, above every tested method.
- It uses ordinary MIT-licensed gems and 2 small scripts with their own tests.
- The full suite still guards every release in CI.

## Rollout for an existing codebase

1. Run `setup-project` on one repository. Old code does not fail the build, because every gate applies only to changed code.
2. Map the risk once: `bundle exec skunk app lib` and `bundle exec simplecov uncovered --missing`. Share the 10 worst files. Skunk, RubyCritic, and Flog are optional and not part of `setup-project`'s default gem list; add them by hand first (`setup.md`, "Skunk report (optional)").
3. Turn on the `verify-change` job for pull requests.
4. Start the mutation threshold at 75%. Raise it to 85% once the team marks equivalent mutants.
5. For legacy code, add `simplecov ratchet` and a Mutineer baseline so coverage and mutation results never slide back.
6. Pair on the first survivors. The member discount example in `concepts.md` explains the idea in 2 minutes.

## Thresholds

| Check | Limit | Why this number |
|---|---|---|
| Tests for the change | All green | A red test is a failed change. |
| Patch coverage | 100% of changed lines and branches | Every changed line runs in some test. |
| Mutation score on changed lines | 75%, then 85% | A real first change scored 66.7% with all 11 operators, and its survivors included real test gaps. Raise it once equivalent mutants are marked. |
| CRAP per changed method | 30 or less | The limit of the original CRAP metric. |
| Full suite | Green in CI | A red build stops the release. |

## Limits

- Mutation time grows with the size of a change. Keep pull requests small.
- In Rails, Mutineer runs one mutant at a time unless the app uses `--daemon`, which supports SQLite only in Mutineer 1.0. On Postgres or MySQL, `--rails --daemon --jobs N` errors every mutant instead of running them (measured on Postgres 17; MySQL uses the same adapter check, inferred not measured); `--rails --jobs N` without `--daemon` prints a notice and runs 1 job, correctly. Keep runs small with `--since` on changed lines.
- Pin Mutineer to `~> 1.0` and read its changelog before upgrading.
- Equivalent mutants need a person's judgment.
- Skunk needs RubyCritic 4.12 until Skunk supports RubyCritic 5.
