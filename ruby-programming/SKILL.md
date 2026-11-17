---
name: ruby-programming
description: >
  Writes and designs Ruby that is right on the first draft and easy to change:
  the traps that no linter catches, small objects that receive their
  collaborators, requires that point one way, and data work left to the
  database. Use when writing, reviewing, designing, or refactoring Ruby code:
  a class, a module, a script, a gem, a command-line tool, a migration, or a
  package layout; declaring a base class with hooks; choosing private or
  protected; raising or rescuing errors; building a value object; running a
  child process; or moving code to Ruby 3.4 or 4.0. Also use when a reviewer
  keeps sending Ruby code back, when code passes RuboCop and still reads
  wrong, when Reek or RubyCritic report smells, or when Ruby code loops over
  rows or grows methods that only tests call. For Rails code, this skill
  routes to the Rails method to use. For tests use ruby-testing. For lint,
  coverage, mutation, and CRAP use ruby-quality-checking.
license: MIT
compatibility: Needs Ruby 3.2 or newer to run the proof scripts. The rules hold from Ruby 3.0.
metadata:
  author: Zlatko Alomerovic
---

# Ruby programming

The `simple-architecture-designing` skill sets how to approach the work, and its rules hold in every language. This skill applies them to Ruby and adds the traps that only Ruby has. RuboCop, Standard, and Rails Omakase stay silent on the traps below, so they have to be known.

## Objects

- Give a class that does one job a public `call`, and a class method `def self.call(...) = new(...).call` that builds and runs it. Never name it `run`. Keep `self.call` a shortcut only, never a class that holds state.
- Pass every collaborator that does input or output in as a keyword argument with the production default: `def initialize(io: $stdout, clock: Time)`. Read `ENV`, `Time.now`, and `$stdout` once, at the entry point.
- Keep a class to 100 lines, a method to five lines, and a method to four parameters. These are Sandi Metz's rules, the Ruby measure of the smallest design that fits.
- Use `Data.define` for a value, a parameter group, and a result. A class that defines `==` also defines `eql?` and `hash`, because `Hash` and `Set` use those two.
- Use `fetch` for a required hash key. Convert or reject input in the first lines of a public method, then trust it.

## Hooks and visibility

- Declare every hook and every constant that a base class reads. Declare the hook `private` and raise `NoMethodError` with the class name. Never raise `NotImplementedError`: it is a `ScriptError`, so a plain `rescue` misses it. An undeclared hook raises `NameError`, which a `rescue NoMethodError` also misses.
- In a base class, `call` raises `NoMethodError, "#{self.class} must define call"`, and nothing runs before it: no parsing, no setup.
- Write `private` again above the hook in each subclass. A plain `def` in a subclass is public, whatever the parent declared.
- Use `private` unless one object must call the method on another object of the same class, as in `balance > other.balance`. Only that case needs `protected`, and a subclass that redefines a protected method breaks the parent's call.

## Errors

- Raise a named error for a failure that stops the work, and let one boundary, the entry point, turn it into an exit code or a response. Return a value only for an outcome that the caller handles as a normal branch, such as a declined payment. Never return `nil` to mean "failed".
- Use `raise`, never `fail`. The Ruby Style Guide and RuboCop both say so.
- Use `and` and `or` only as a trailing `or raise` or `and return`. Never use them to produce a value: `report and USAGE` returns `nil` when `report` returns `nil`.

## Files, processes, and loading

- Add a `require_relative` for every constant that a file names, from its own layer or below. Never rely on another file to have loaded it. A circular require warning under `ruby -w` is a failure.
- Pass a list of arguments to `system`, or use `Open3`. One command string goes through a shell, and a path that holds `;` becomes a command.
- Treat a process status as a value. `exitstatus` is `nil` for a child that a signal killed, so `status.exitstatus || 1` reports a plain failure.
- Sort the result of `Dir.glob` on purpose. The default order is by byte, so `b10` comes before `b9`.

## Idioms

- Forward arguments with `...`. `*args, &block` loses keyword arguments.
- Replace an `each` that fills an accumulator with `map`, `select`, `sum`, `group_by`, `to_h`, or `each_with_object`.
- Use the standard library before writing a helper. `DidYouMean::SpellChecker` corrects a typed command name.
- Keep only the comment lines that Ruby reads, such as `# frozen_string_literal: true`.

## Data and smells

- A migration or a data change is one set-based statement, such as `update_all` or one `INSERT ... SELECT`, never a loop that loads and saves each row. A migration never loads application models.
- Fix a Reek or RubyCritic finding in the design. Never hide it in `.reek.yml` or a `.rubocop_todo.yml` entry.
- A test calls only public methods: no `send`, no `instance_variable_get` or `instance_variable_set`. It replaces a dependency through the constructor.

## Tasks

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. `SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict or invent what a script prints.

| When | Do |
|---|---|
| Deciding how large a class or a method may grow, or where a responsibility belongs | Read `references/design-rules.md`. |
| Fixing a Reek smell, a require cycle, a class-level singleton, a global clock, a row loop, or code only tests call | Read `references/design-fixes.md`. |
| Raising, rescuing, or defining an error class; using `ensure`, `Timeout`, or `cause` | Read `references/exceptions.md`. |
| Writing a base class with hooks, or choosing `private`, `protected`, or `private_constant` | Read `references/visibility.md`. |
| Building a value object, defining `==` or `<=>`, or choosing `Data` or `Struct` | Read `references/values-and-equality.md`. |
| Using `method_missing`, `define_method`, `prepend`, `alias_method`, or `refine` | Read `references/metaprogramming.md`. |
| Delegating a call, or mixing positional, keyword, and block arguments, procs, and lambdas | Read `references/arguments.md`. |
| Naming a constant across files, or using `require`, `require_relative`, or `class A::B` | Read `references/constants-and-loading.md`. |
| Building, parsing, sorting, or aligning strings and collections | Read `references/strings-and-collections.md`. |
| Running a child process, reading `$?`, writing a file, globbing, or printing to a stream | Read `references/files-and-processes.md`. |
| Memoizing a value, or sharing state between threads or Ractors | Read `references/memoization-and-threads.md`. |
| Writing for Ruby 3.4 or 4.0, or following advice written for an older Ruby | Read `references/ruby-4-changes.md`. |
| Parsing command-line options | Read `references/option-parser.md`. |
| The code is in a Rails application | Read `references/rails.md` first. It names the Rails method to use and the traps that the guides document. |
| Designing a schema, a query, a transaction, or a migration | Use the `database-designing` skill. |
| Choosing between two designs, or reading architecture findings such as cycles or layer breaks | Use the `simple-architecture-designing` skill. |
| A rule here is doubted, or a Ruby upgrade may have changed it | Run the matching script: `ruby SKILL_DIR/scripts/NN_name.rb`. Each reference names its script. |
| Someone asks where a rule comes from | Read `references/sources.md`. |
