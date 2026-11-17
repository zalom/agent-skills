# Design rules: simple code that is easy to change

## The order of concerns

1. Make it right: the traps in `SKILL.md` and these references.
2. Make it small: the limits below.
3. Make it plain: no clever construct where a plain method does the job.

Speed comes last, and only with a measurement.

## Size limits

These are Sandi Metz's rules. Break one only with a reason that can be said in one sentence.

- A class holds 100 lines or fewer.
- A method holds five lines or fewer.
- A method takes four parameters or fewer. Keys of an options hash count.
- A Rails controller action creates one object, and the view reads one instance variable.

A method that needs a comment to explain a step is two methods. Give the step a name and the comment goes away.

## No comments

Code carries itself through names and small methods. The commit message and the pull request description carry what changed and why. Keep only the lines that Ruby reads, such as `# frozen_string_literal: true`, and a `# rubocop:disable` line with its reason when a rule must be turned off for one line. A block of prose above a class is a sign that the class name is wrong or that the class does two jobs.

## Where a responsibility belongs

- Ask what the object knows and what it is asked to do. A method that uses only its arguments and none of the object's state belongs somewhere else. Reek reports this as `UtilityFunction`.
- Call a method once and keep the result in a local variable, when the same call appears twice in one method. Reek reports this as `DuplicateMethodCall`.
- Pass collaborators in. Give IO, `ENV`, the clock, the home directory, and other objects as constructor or method arguments with real defaults. A test then passes its own. Never read `ENV` or `Dir.home` deep inside the code.
- Depend on a message, not on a class. A caller that needs `call` takes anything that answers `call`.
- Prefer a plain object with two methods to a module that is mixed in. Use inheritance for a real "is a" with a shared, stable base. Declare its hooks, as `references/visibility.md` shows.

## Idioms worth keeping

- Guard clauses at the top of a method in place of nested conditions.
- `fetch` for a key that must exist: `config.fetch(:api_key)` raises `KeyError` with the key's name.
- `Data.define` for a value. See `references/values-and-equality.md`.
- `filter_map`, `tally`, `sum`, `each_with_object`, and `to_h` with a block, before a hand-written loop.
- A domain error base class per library, `class Error < StandardError; end`, with specific errors below it. Rescue the narrowest one that the code can handle.
- For a failure that is an expected outcome, such as a declined payment, return a value that says so. Keep exceptions for the unexpected.

## Tools that help, and their limits

- The linter is a safety net for known faults. It does not catch the rules in `SKILL.md`.
- Reek finds design smells that the linter misses. Read it as a report. As a gate it demands a comment on every class, which breaks the no-comments rule; turn off `IrresponsibleModule` when it runs.
- The Ruby LSP answers "where is this defined" and "who calls this", also inside gems. Use it before a text search.
- Skip type checkers and package boundary tools until the project has the problem that they solve.
