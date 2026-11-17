---
name: ruby-designing
description: >
  Designs Ruby code for the least complexity: small objects that receive their
  collaborators, requires that point one way, data work left to the database, and tests of
  public behavior. Use when designing or reviewing a Ruby class, module,
  command, migration or package layout; reading Reek, RubyCritic, CRAP or
  architecture findings such as cycles, god classes or dead code in a Ruby
  project; or when Ruby code loops over rows, names classes by number, or grows
  methods only tests call. For the line-level traps of a first draft use
  ruby-writing.
license: MIT
metadata:
  author: Zlatko Alomerovic
---

# Ruby designing

Do more with less. The `simple-architecture-designing` rules hold in every language; these add what Ruby needs.

## Rules

- Pass every collaborator that does input or output in as a keyword argument with the production default: `def initialize(io: $stdout, clock: Time)`. Read `ENV`, `Time.now` and `$stdout` once, at the entry point.
- Make a class an instance with its dependencies in `initialize`. Keep `self.call(...) = new(...).call` only as a shortcut, never as a hidden singleton that holds state on the class.
- Each file requires only what it references at load time, from its own layer or below. A circular require warning under `ruby -w` is a failure.
- Use a value object (`Data.define`) for a parameter group and for a result. Return a result or a null object, never `nil` for "failed".
- Use `fetch` for required hash keys. Convert or reject input in the first lines of a public method, then trust it.
- Replace an `each` that fills an accumulator with `map`, `select`, `sum`, `group_by`, `to_h` or `each_with_object`.
- Leave data work to the database. A migration or a data change is one set-based statement, never a Ruby loop that loads and saves each row, and it never loads application models. The `database-designing` skill holds the rules for schemas, queries and migrations.
- A Reek or RubyCritic finding is fixed in the design, not hidden in `.reek.yml` or a `.rubocop_todo.yml` entry.
- Tests call only public methods: no `send`, no `instance_variable_get` or `instance_variable_set`. A test replaces a dependency through the constructor.

## Tasks

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. `SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict or invent what a script prints.

| When | Open |
|---|---|
| Deciding how large a class or method may grow, or where a responsibility belongs | `references/design-rules.md` |
| Fixing a Reek smell, a require cycle, a class-level singleton or a row loop | `references/design.md` |
| Writing a line of Ruby right on the first draft: visibility, exceptions, values, arguments, processes, Ruby 4 | the `ruby-writing` skill |
| Designing the schema, a query or a migration | the `database-designing` skill |
| Writing or refactoring the tests | the `ruby-testing` skill, and the testing page of `simple-architecture-designing` for what to test |
