# Fixing findings

What to do when a check in `bin/verify-change` fails. Open the section named in its `Failed:` line.

## Tests with coverage

A test failed. Fix the code or the test. Never loosen an assertion until it passes.

## Patch coverage

Some changed lines or branches never ran in a test.

1. List the missed lines: `bundle exec simplecov show lib/refund.rb --uncovered-only`.
2. For missed branches, open `coverage/index.html`, click the file, and look for yellow marks.
3. Write a test that reaches each missed line or branch. A line no input can reach is dead code: delete it.

## Mutation testing

A mutant survived, or a changed line had no coverage.

1. Read the diff Mutineer prints for the survivor.
2. Find an input for which the original code and the mutant return different results. It is usually a boundary value or the exact result.
3. Write a test with that input that asserts the exact expected result. In RSpec, that is an example with `expect(result).to eq(expected)`.
4. Run Mutineer on the file again and confirm the mutant is killed. In an RSpec project, pass the spec file and add `--framework rspec`:

   ```sh
   bundle exec mutineer run lib/refund.rb --test test/refund_test.rb --strategy redefine --since main
   ```

The operator in the report points at the test to write:

| Operator | Example | Test that kills it |
|---|---|---|
| `comparison` | `>=` becomes `>` | The boundary value itself, such as exactly 100_00. |
| `literal_mutation` | `100` becomes `101` | An exact result that depends on the number. |
| `arithmetic` | `*` becomes `/` | An exact result, with inputs other than 1. |
| `boolean_connector` | `&&` becomes `\|\|` | One condition true and the other false. |
| `condition_negation` | `if paid` becomes `if !(paid)` | Both branches, each with its exact result. |
| `return_nil` | The return value becomes `nil` | An assertion on the return value, not only on side effects. |
| `statement_removal` | A statement is dropped | An assertion on that statement's effect. |
| `collection_method` | `max` becomes `min` | Input where the two results differ. |
| `string_literal` | `"SAVE5"` becomes `""` | The exact string, and a near miss such as `"save5"`. |
| `regex` | `^` is dropped | Input that matches only in the middle of the string. |

## Equivalent mutants

Some mutants cannot be killed, because no input can tell them apart from the original. Example: dropping `return 0 if items.empty?` before `items.sum { ... }` changes nothing, because the sum of an empty list is already 0.

State why a survivor looks equivalent before suppressing it; a person decides whether that
reasoning holds, this skill never decides alone.

1. First, simplify the code so the mutant disappears. In the example, delete the redundant guard.
2. If the code must stay, suppress the mutant with the reason next to it:
   - inline: `# mutineer:disable-line statement_removal`, or
   - in `.mutineer.yml`: run with `--format json`, take the survivor's `id` under
     `survivors[].id` (12 hex characters, a content-based digest of the mutant, not a file or
     line reference), and add it under `ignore:`. `.mutineer.yml`'s `ignore:` is a flat array
     of ids; there is no structured reason field, so give the reason as a YAML comment on the
     same line.
3. Rerun and read the `Ignored:` line to confirm the suppression took. A run where every
   mutant ends up ignored reports mutation score `N/A` and skips the threshold gate, the same
   as a run with no covered mutants.
4. After 2 failed attempts to kill the same survivor, stop and ask a person whether it is equivalent. Never loop on it.

## CRAP scores

A changed method scores above 30.

1. If its coverage is under 100%, add tests first. Full coverage lowers the score to the complexity.
2. If the score is still above 30, the method has too many paths. Split it into small named methods: one per decision, or a lookup table in place of a long `case`.
3. Run the whole check again. A split can create new mutants to kill.

## Skunk

Skunk is a report, not a gate. Take the worst file, add tests first, then refactor.
