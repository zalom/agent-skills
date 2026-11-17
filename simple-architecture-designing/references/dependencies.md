# Dependencies, layers and data

A dependency is a promise that one part changes when another does. Keep few of them, keep them weak, and point them toward what changes less.

## Where a dependency points

- Layers depend downward only: the shell (command line, web, hooks) on the use cases, the use cases on the domain and storage. A lower layer never names a type from a higher one (Robert Martin, acyclic and stable dependencies).
- The shared core depends on nothing above it. A package that everything uses must also be the one that changes least.
- The core never names an extension. Extensions depend on the core and load by name (Sequel and Roda plugins).
- A file loads only what it uses at load time, from its own layer or below.

## Break a cycle

Two packages that reach each other are one package with two names. To split them:

1. Find the edge that points upward, the one a lower part takes from a higher one.
2. Move what it takes (an error type, a constant, a value type) down into the lower part, or into a third, lower package that both use.
3. When the lower part must call the higher one, invert the edge: the lower part names a role, and the higher part passes in an object that plays it.

A root package that both holds the shared kernel and loads every other package puts every package in one cycle. Keep the kernel and the composition root apart.

## Coupling, weakest first

Jim Weirich's connascence: two pieces of code are connascent when changing one forces a change in the other. From weak to strong: name, type, meaning, position, algorithm, then the dynamic forms (execution order, timing, value, identity).

- Across files and packages, couple only by name: keyword arguments, method names, named constants.
- A value with meaning (a status, a file pattern, a magic number) is defined once.
- Replace positional arguments with names or with one parameter object.
- Remove order coupling ("call setup before run") by doing the setup in the constructor or by returning a new object.
- Strong coupling inside one method is fine. Strength must fall as distance grows.

## Collaborators come in

- Every collaborator that does input or output (the database, files, the clock, the environment, the terminal) is passed in, with the production value as the default.
- Read the environment, the clock and the terminal once at the entry point, and pass values down.
- A global is a hidden parameter of every function that reads it. One composition root builds the objects and passes them down.
- A class names another class only where it creates it, and it creates it in one place.
- Talk to immediate neighbors only: no `a.b.c` chains through objects you did not create or receive.

## Polymorphism over type checks

- A switch on a collaborator's type belongs only in the one factory that picks the class.
- "Nothing" and "failed" are objects (a null object, a result value), not a null every caller must check.
- A variant that combines with another variant is an injected role, not a subclass.
- Extract an abstraction at its third use, and only with a clear name. A shared method that grew a flag per caller goes back inline (Sandi Metz, "The Wrong Abstraction").

## Data stays in the database

- Rows that stay in the database move with one set-based statement in one transaction: `INSERT ... SELECT`, `UPDATE ... FROM`. In SQLite, `ATTACH` brings a second file onto the same connection, and in rollback journal mode one transaction over attached files is atomic.
- A whole-database copy uses the engine's copy (`VACUUM INTO`, the backup API), never a row loop.
- A row loop in code is only for a change the query language cannot express. It then runs in one explicit transaction with one prepared statement.
- In SQLite's WAL mode a transaction over attached files is atomic per file only. Choose the journal mode before relying on cross-file atomicity.

## Migrations

- Name a migration after what it does, with its version as a prefix only. A number alone says nothing.
- A migration uses the query language only and never loads application code, so later code changes cannot break it.
- Migrations that no released database has run can still be folded into one before the release. After the release, a landed migration never changes; a schema snapshot builds a new database.

## Fewest elements

Kent Beck's four rules, in order: passes the tests, reveals intention, no duplication, fewest elements. Every class, method, option and parameter has a production caller today. A hook for a future need is speculative generality: leave it out.

## Sources

Sandi Metz, *Practical Object-Oriented Design* (chapters 3, 4 and 6), "Nothing is Something" and "The Wrong Abstraction". Jim Weirich, "The Grand Unified Theory of Software Design" and "Connascence Examined". Kent Beck's rules of simple design. Gary Bernhardt, "Boundaries". Robert Martin's package principles. Martin Fowler, *Refactoring*. The code of Sequel, Roda, Rack, Hanami, dry-system, Rake, Minitest, Bundler and Rails. The SQLite documentation on `ATTACH`, WAL and `VACUUM INTO`.
