# Migrations

A migration changes the schema or the data. It must be safe to run on a live database and safe to read years later.

## Contents

- Shape of a migration
- Expand, migrate, contract
- Backfills
- The schema snapshot
- Version stamps
- Transactions and locks
- Sources

## Shape of a migration

- Change the schema in small, reversible steps, each one deployed and tested.
- Name a migration after its purpose (`AddPaidAtToOrders`, `CreateMemberships`), with a version only as a prefix. A number or a ticket alone says nothing.
- Write a migration in the query language or the schema API only. Never load application models, so a later model change cannot break an old migration.
- Change data with one set-based statement, never a loop over rows.
- Write one change per migration, so a half-applied run is easy to finish by hand.
- Keep a landed migration unchanged once any released database has run it. Fix forward with a new migration.
- Squash migrations that no deployed database has run into one before the release. Delete old migrations once every database has applied them and the snapshot covers them.

## Expand, migrate, contract

A breaking change goes out in three releases.

1. Expand: add the new column or table. Old code keeps working.
2. Migrate: write to both shapes, backfill old rows, then move every reader to the new shape.
3. Contract: drop the old column or table in a later release, after nothing reads it.

- Rename a column or change its type the same way. A direct rename breaks the running release.
- Add a not-null or a foreign key in two steps where the engine allows: add the constraint without validation, then validate it. Check the engine's documentation.
- Drop a column only after the code stopped reading and writing it.

Example, renaming `orders.total` to `orders.total_cents`:

```sql
-- release 1, expand
ALTER TABLE orders ADD COLUMN total_cents INTEGER;
-- release 2, migrate: code writes both columns, then
UPDATE orders SET total_cents = total * 100 WHERE total_cents IS NULL;
-- release 3, contract, after no code reads total
ALTER TABLE orders DROP COLUMN total;
```

## Backfills

- Backfill outside the schema migration, in batches, so a long data change holds no schema lock.
- Make a backfill restartable: select the rows still to do (`WHERE total_cents IS NULL`) rather than counting from an offset.
- Keep each batch a single set-based statement with a bounded key range.
- Use one statement for a small table that fits in one short transaction.

## The schema snapshot

- Build a new database from the schema snapshot, not by replaying every migration. Old migrations may no longer run.
- Use the SQL form of the snapshot when the schema has triggers, views, checks or engine features the framework's schema file cannot express.
- Commit the snapshot with the migration that changes it.

## Version stamps

- Record the applied version in the database: a migrations table, a single version row, or the engine's own version slot where it has one.
- Write the stamp in the same transaction as the change, so the version and the schema never disagree.

## Transactions and locks

- Run each migration in a transaction where the engine can roll back schema changes. Check the engine's documentation. Where it cannot, write each migration so a half-applied run can be finished by hand.
- Check whether a schema statement commits the open transaction.
- Set a short lock timeout for migrations on a busy server, so a blocked change fails fast instead of queueing every query behind it.
- Build indexes online where the engine offers it, and ask for the algorithm you expect, so the statement fails rather than silently copying the table.
- Check which schema statements lock reads or writes on a big table before running them.

## Sources

- Scott Ambler and Pramod Sadalage, *Refactoring Databases* (Addison-Wesley, 2006): https://databaserefactoring.com
- Martin Fowler and Pramod Sadalage, "Evolutionary Database Design": https://martinfowler.com/articles/evodb.html
- Danilo Sato, "Parallel Change" (2014): https://martinfowler.com/bliki/ParallelChange.html
- strong_migrations README: https://github.com/ankane/strong_migrations
- Sequel migration guide: https://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html
- Django migrations (squashing): https://docs.djangoproject.com/en/5.2/topics/migrations/
