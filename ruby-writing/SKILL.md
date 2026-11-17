---
name: ruby-writing
description: >
  Writes plain Ruby that is right on the first draft: the rules that no linter
  catches and that cost a review round when missed. Use when writing,
  reviewing, or refactoring Ruby code: a class, a module, a script, a gem, or
  a command-line tool; declaring a base class with hooks that subclasses fill
  in; choosing private or protected; raising or rescuing errors; building a
  value object; forwarding arguments; running a child process or reading its
  exit status; globbing files; or moving code to Ruby 3.4 or 4.0. Also use
  when a reviewer keeps sending Ruby code back, or when code passes RuboCop
  and still reads wrong. For Rails code, this skill routes to the Rails method
  to use. For tests use ruby-testing. For lint, coverage, mutation, and CRAP
  use ruby-quality-checking.
license: MIT
compatibility: Needs Ruby 3.2 or newer to run the proof scripts. The rules hold from Ruby 3.0.
metadata:
  author: Zlatko Alomerovic
---

# Ruby writing

Write the simplest Ruby that is easy to change, and get the traps below right before the first review. RuboCop, Standard, and Rails Omakase were run against the first three rules and against long comment blocks, and all three linters stayed silent. These rules have to be known, because nothing else reports them.

## Rules

- Give a class that does one job a public `call`, and a class method `def self.call(...) = new(...).call` that builds and runs it. Never name it `run`. In a base class, `call` raises `NoMethodError, "#{self.class} must define call"`, and nothing runs before it: no parsing, no setup.
- Declare every hook and every constant that a base class reads. A hook is a method that the base class calls on itself and each subclass defines. Declare it `private` in the base class and raise `NoMethodError` with the class name. Never raise `NotImplementedError`: it is a `ScriptError`, so a plain `rescue` misses it. An undeclared hook raises `NameError`, which a `rescue NoMethodError` also misses.
- Write `private` again above the hook in each subclass. A plain `def` in a subclass is public, whatever the parent declared.
- Use `private` unless one object must call the method on another object of the same class, as in `balance > other.balance`. Only that case needs `protected`, and a subclass that redefines a protected method breaks the parent's call.
- Use `and` and `or` only as a trailing `or raise` or `and return`. Never use them to produce a value: `report and USAGE` returns `nil` when `report` returns `nil`.
- Forward arguments with `...`. `*args, &block` loses keyword arguments.
- Define `==`, `eql?`, and `hash` together, or use `Data.define`. `Hash` and `Set` use `hash` and `eql?`, so `==` alone hides the fault.
- Add a `require_relative` for every constant that a file names. Never rely on another file to have loaded it.
- Pass a list of arguments to `system`, or use `Open3`. One command string goes through a shell, and a path that holds `;` becomes a command.
- Treat a process status as a value. `exitstatus` is `nil` for a child that a signal killed, so `status.exitstatus || 1` reports a plain failure. Map a signal and an unknown code on purpose.
- Sort the result of `Dir.glob` on purpose. The default order is by byte, so `b10` comes before `b9`.
- Use `raise`, never `fail`. The Ruby Style Guide and RuboCop both say so.
- Write code that needs no comment. Names, small methods, and the commit message carry the meaning. Keep only the magic comment lines that Ruby reads, such as `# frozen_string_literal: true`.
- Use the standard library before writing a helper. `DidYouMean::SpellChecker` corrects a typed command name. A distance built from `left.chars - right.chars` scores every anagram as a match, because `Array#-` is a set operation.

## Tasks

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. `SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict or invent what a script prints.

| When | Do |
|---|---|
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
| Deciding how large a class or a method may grow, or where a responsibility belongs | Read `references/design-rules.md`. |
| The code is in a Rails application | Read `references/rails.md` first. It names the Rails method to use and the traps that the guides document. |
| A rule here is doubted, or a Ruby upgrade may have changed it | Run the matching script: `ruby SKILL_DIR/scripts/NN_name.rb`. Each reference names its script. |
| Someone asks where a rule comes from | Read `references/sources.md`. |
