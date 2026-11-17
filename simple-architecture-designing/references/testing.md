# What to test, and at which layer

A test earns its place when it fails because behavior changed and passes when only the structure changed. Test as little as gives that confidence.

## What to test

Sort every message an object takes or sends, then test it by its kind.

| Message | Test it by | Never |
|---|---|---|
| An incoming query | The value it returns | Its private steps |
| An incoming command | The public change it makes: a row, a file, an exit code | The order of its internal calls |
| An outgoing command | That it was sent, with the right arguments, to a double | Its effect inside the other object |
| An outgoing query | Nothing: stub it to return a value | An expectation on it |
| A private method | Nothing. When it needs its own test, extract it into a small public object | Reflection to reach it |

Skip what cannot really break, such as plain accessors and constructors.

## Real collaborators first

- Put decisions in pure functions that take and return values, and test them with no doubles.
- Use the real collaborator by default: a real database file in a temporary folder, real files, real processes in end-to-end tests.
- Use a double only for something slow, external or nondeterministic: the network, the clock, another service.
- Never mock a library you do not own. Wrap it in a small class you own, and fake that.
- Never fake part of the object under test.

## Seams, not test-only code

- Inject the clock, the home folder and the output stream through the same path the production entry point uses.
- Add no method, flag or branch that only tests call. If a test needs one, the design is missing a real seam.

## Isolation

- No test reads the real clock or depends on elapsed time.
- Each test makes its own temporary home and database, and nothing survives it.
- A test that changes the environment, the working folder or a global setting restores it.
- Tests pass in random order.

## The layers

| Layer | What it runs | How many |
|---|---|---|
| Unit | One object or function in-process, temporary files allowed | Most of the suite |
| Integration | Several real parts in-process, with the real database and files in a temporary home | One per collaboration that can break |
| End-to-end | The real program as a subprocess, on a fresh temporary home | About one per command or option, checking only output, exit code and files on disk |

Use these three names. Names such as "system" or "functional" mean different things in different frameworks, so they surprise a reader.

## Guards

A test that searches the codebase for a repository rule is lint, not behavior. Keep such checks in one file or task, apart from the behavior suite.

## Sources

Sandi Metz, "The Magic Tricks of Testing" (2013) and *Practical Object-Oriented Design*, chapter 9. Kent Beck, "Test Desiderata". Gary Bernhardt, "Boundaries". Martin Fowler, "UnitTest" and "Mocks Aren't Stubs". Justin Searls, "Please don't mock me". David Heinemeier Hansson, "Test-induced design damage".
