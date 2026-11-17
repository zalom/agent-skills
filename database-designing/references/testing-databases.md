# Testing databases

Test data code on the real engine. The behavior lives in the server.

## Contents

- The engine
- Isolation
- Schema and migrations
- Fixtures
- Constraints
- Other stores
- Sources

## The engine

- Test against the same engine and version as production, never a mock or a different engine.
- Never mock a database library you do not own. Wrap it in a small class you own and fake that.
- Put decisions in pure functions that take and return values, and test them with no database.
- Use a real database for the code that touches it: a file in a temporary folder, or a server in a container.

## Isolation

- Wrap each test in a transaction and roll it back afterward, or give each test a fresh database.
- Turn the wrapping transaction off only for code that spans connections or commits itself, and clean those tables explicitly.
- Give each test its own key prefix, database or index name where a transaction cannot isolate it.
- Never read the real clock to decide a result. Inject the clock.

## Schema and migrations

- Load the test schema from the snapshot and fail on pending migrations.
- Test the migrator once, with tiny fixture migrations, on a real database.
- Keep one test or one CI step that migrates an empty database to the newest version and compares the dumped schema with the committed snapshot. A difference means a migration and the snapshot disagree.
- Write no test per migration.
- Keep a check that landed migrations never change as one guard or startup check, apart from the behavior tests.

## Fixtures

- Use fixtures or a small factory set that satisfy every constraint. A fixture that needs constraints switched off hides a broken schema.
- Run the engine's integrity check after a bulk load in tests. Check the engine's documentation for it.

## Constraints

- Test the constraints themselves: insert a row that breaks each check and unique constraint and assert the error.

## Other stores

- Run tests against the real store, in a container or a local install. Expiry, eviction and validation live in the server.
- Give each test its own key prefix, database or index, and drop it afterward.
- Test the rebuild path of every derived store: drop the cache or index and check the application still answers from the source of truth.

## Sources

- Steve Freeman and Nat Pryce, *Growing Object-Oriented Software, Guided by Tests* (2009): only mock types that you own.
- Sequel `doc/testing.rdoc`: core specs against a mock adapter, adapter specs against a real database.
- Martin Kleppmann, *Designing Data-Intensive Applications* (O'Reilly, 2017), chapters 11 and 12, on derived data.
