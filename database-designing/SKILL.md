---
name: database-designing
description: >
  Designs data storage for the least complexity: schemas that hold their own rules,
  set-based queries, one transaction, safe migrations, tests on the real engine, and
  a second store only when it earns its place. Use when designing a schema, key,
  index, query, transaction or migration; choosing a database or deciding whether to
  add a cache, document store, search index or queue; reviewing a data change that
  loops over rows; renaming a column on a live table; or testing data code. Also use
  for indirect requests such as "speed up this report query", "where should we store
  sessions", "copy these rows between two databases" or "why did the deploy lock the
  table".
license: MIT
metadata:
  author: Zlatko Alomerovic
---

# Database designing

Let the database hold the truth. Declare the rules as constraints, change data with set-based statements in one transaction, and add a second store only when a named need earns it. These rules hold for any engine. Where one depends on an engine feature, check the engine's documentation for it.

## Rules

- Declare every rule about the data in the schema: primary key, not-null, check, unique, foreign key. A rule kept only in application code fails for the next writer.
- Normalize to third normal form, then stop. Denormalize only for a read path that was measured, and keep the copy correct with a constraint, a generated column or a trigger.
- Change many rows with one set-based statement, never a loop that loads and saves each row. Rows that stay in the database never pass through application code.
- Put writes that must succeed or fail together in one transaction. When all the writes land in one database, use that transaction instead of an outbox, a saga or a retry queue.
- Keep a transaction short. Never hold one open across a network call or user input.
- Make a retried write safe with a unique key the client sends, stored in the same transaction as the work.
- Ship a breaking schema change as expand, migrate, contract: add the new shape, move readers and writers, then drop the old shape in a later release.
- Write a migration in the query language only. It never loads application models, and it is named after what it does, not after a number or a ticket.
- Build a new database from the schema snapshot, not by replaying every migration. A migration that a released database has run never changes.
- Test on the same engine and version as production, never a mock or a different engine. Test a constraint by breaking it.
- Start relational. A second store earns its place only when a named access pattern needs what the relational database cannot give at the required scale, and the cost of the second store is paid on purpose.
- Name the source of truth for each fact. Every other copy is a cache or an index and can be dropped and rebuilt from the source.
- Check the engine's documentation before relying on a default: foreign key checks, locking during schema change, and whether schema changes can be rolled back differ between engines.
- Store points in time in UTC and convert only for display. Store money as exact decimals or integer minor units.
- Read the query plan before and after adding an index. Drop an index no query uses.

## Tasks

Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. `SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict or invent what a script prints.

| When | Open |
|---|---|
| Modeling tables, keys, constraints, types, naming or normal forms | `references/modeling.md` |
| Writing a query, an index, a transaction, an idempotent write, or moving rows between tables or databases | `references/queries-and-transactions.md` |
| Writing a migration, renaming or retyping a column on a live table, backfilling, or stamping a version | `references/migrations.md` |
| Writing a test that touches a database, a fixture, a schema check or a migration test | `references/testing-databases.md` |
| Asked whether to add a cache, document store, search index or other store, or where data should live | `references/choosing-a-store.md` |
| Designing the code around the data: layers, injected collaborators | the `simple-architecture-designing` skill |
