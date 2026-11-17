# Queries and transactions

Rules for any relational engine. Where a rule needs an engine feature, check the engine's documentation for it.

## Contents

- Set-based statements
- Indexes
- Transactions
- Idempotent writes
- One database, no outbox
- Moving data between tables and databases
- Sources

## Set-based statements

- Change many rows with one statement, not one statement per row from a loop. Round trips dominate response time.
- Copy or derive rows with `INSERT ... SELECT`.
- Update from another table with the engine's update-from or update-join form.
- Insert or update in one upsert statement keyed on a unique constraint.
- Return written rows with a returning clause where the engine has one, instead of a second select.
- Name each step of a long query with a common table expression. Walk trees with a recursive one.
- Rank, number and total within groups with window functions, not a correlated subquery per row.
- Load associations with a join or one `IN (...)` query per association, never one query per parent row (the N+1 query).
- Make the N+1 query fail in development and tests, not only in review.
- Page with a keyset (`WHERE id < :last_seen ORDER BY id DESC LIMIT 20`), not a growing offset.

```sql
INSERT INTO invoice_lines (invoice_id, product_id, cents)
SELECT 7, product_id, price_cents FROM cart_items WHERE cart_id = 3;
```

## Indexes

- Order the columns of a multi-column index by how queries filter. Only a leftmost prefix of the index can be used.
- Index for equality first, then for ranges.
- Never wrap an indexed column in a function in the filter. Index the expression instead, and write the query with the same expression.
- Avoid a leading wildcard in `LIKE`. It cannot use an ordered index.
- Read the query plan before and after adding an index.
- Drop indexes no query uses. Each one costs every write.

## Transactions

- Put every write that must succeed or fail together in one transaction.
- Keep transactions short, and never hold one open across a network call or user input.
- Know the engine's default isolation level and what it allows. Check the engine's documentation.
- Under strict isolation, retry the whole transaction on a serialization failure.
- Prefer one atomic statement (`UPDATE ... SET n = n - 1 WHERE n > 0`) or a constraint to a read followed by a write in application code.
- Lock a row you read in order to change it (`SELECT ... FOR UPDATE`, or the engine's equivalent such as an immediate write transaction).
- Check that every error and every result is read. A write that failed silently is the worst bug.

## Idempotent writes

- Make a write that may be retried idempotent: the client sends a unique key, and the write stores it under a unique constraint in the same transaction as the work.
- Let a duplicate key return the first result, not an error and not a second effect.

```sql
INSERT INTO payments (idempotency_key, order_id, cents) VALUES ($1, $2, $3)
ON CONFLICT (idempotency_key) DO NOTHING RETURNING id;
```

## One database, no outbox

- Skip the outbox, the saga and the retry queue when every effect lands in the same database. A plain transaction already makes them atomic.
- Use a transactional outbox only when a write must also reach a system outside the database. Write the message row in the same transaction, publish it afterward, and make the consumer idempotent.
- Keep a database-backed job queue in the same database as the data when a job must commit with the data. In a separate database the enqueue is not atomic with the business write.

## Moving data between tables and databases

- Move rows that stay in the database with one set-based statement in one transaction.
- Copy a whole database with the engine's own copy or backup, never a row loop.
- Use a row loop in code only for a change the query language cannot express. Then run it in one explicit transaction with one prepared statement, in batches.
- Never pass rows through application code to move them between two databases the engine can join. Check the engine's documentation for attaching or linking a second database.
- Check what a transaction guarantees across two databases or files before relying on it. Some engines make it atomic only in certain journal modes.

## Sources

- Markus Winand, Use the Index, Luke: https://use-the-index-luke.com and https://use-the-index-luke.com/no-offset
- Bill Karwin, *SQL Antipatterns, Volume 1* (2022), "Index Shotgun" and "See No Evil".
- Brandur Leach, "Implementing Stripe-like Idempotency Keys" (2017): https://brandur.org/idempotency-keys
- Chris Richardson, Transactional outbox: https://microservices.io/patterns/data/transactional-outbox.html
- Martin Kleppmann, *Designing Data-Intensive Applications* (O'Reilly, 2017), chapters 7 and 11.
