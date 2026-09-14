# CI

The full suite runs in CI, and a red build stops the release. Local runs and agents check only the change.

## The workflow the setup script writes

- A project with no workflow gets `.github/workflows/ci.yml` with 2 jobs:
  - `full-suite` runs every test with coverage on each push to the default branch and on each pull request.
  - `verify-change` runs `bin/verify-change` against the pull request's base branch.
- A project that already has a workflow keeps it and gets `.github/workflows/verify-change.yml` with the second job only. Check that the existing workflow runs the full suite.
- The checkout uses `fetch-depth: 0`, because `bin/verify-change` needs the merge base with the base branch.
- In an RSpec project, `full-suite` runs `COVERAGE=1 bundle exec rspec`, and `bin/verify-change` runs the specs.
- Rails jobs run `bin/rails db:test:prepare` first. Add the app's system packages to the job if its tests need them.

## Any CI

`setup-project` writes GitHub Actions only. On a project whose profile reads GitLab CI or
CircleCI and has no GitHub workflow, it writes no workflow file and prints one line pointing
here instead. Any CI needs the same 2 things:

- The full suite with coverage on every push to the default branch and on every merge
  request or pull request: `COVERAGE=1 bundle exec rake test` (or the project's own test
  command).
- `bundle exec bin/verify-change` against the target branch on a merge or pull request.
- Full git history for the merge base `bin/verify-change` computes: `fetch-depth: 0` on
  GitHub Actions, `GIT_DEPTH: 0` on GitLab CI. A shallow checkout makes `git merge-base` fail.

A GitLab CI example, stated as not run by this skill (never executed against a live GitLab
project; read it as a starting point, not a measured result):

```yaml
variables:
  GIT_DEPTH: 0

verify-change:
  stage: test
  script:
    - bundle install
    - bundle exec bin/verify-change origin/$CI_MERGE_REQUEST_TARGET_BRANCH_NAME
  rules:
    - if: $CI_MERGE_REQUEST_ID

full-suite:
  stage: test
  script:
    - bundle install
    - COVERAGE=1 bundle exec rake test
```

## When CI is red

1. Stop the release.
2. Open the failed job and find the first failing check.
3. Reproduce it locally with the same command.
4. Fix it on the branch and push again.

## Upgrades for larger teams

| Need | Add |
|---|---|
| Survivors shown on the pull request diff | The `davidteren/mutineer@v1` action. On pull requests it scopes the run to the diff and annotates up to 50 survivors. |
| Uncovered changed lines shown on the diff | A step running `bundle exec simplecov patch --base "$BASE_REF" --annotate github` after the tests. |
| A codebase too weak for an absolute mutation threshold | A scheduled full scan on the default branch that saves a JSON baseline, and `--baseline` on pull requests, which fails only on new survivors. |
| Coverage that must never slide back | `simplecov ratchet` with the baseline file committed. |

A pull request that changes only tests or docs scores zero mutants and passes the mutation check. Keep the scheduled full scan when a team relies on baselines.
