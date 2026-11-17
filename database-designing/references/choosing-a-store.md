# The choice of a store

Start with one relational database. A second store earns its place only when a named access pattern needs something the relational database cannot give at the required scale, and the cost of the second store is paid on purpose.

## Contents

- Default
- The kinds of store
- When a second store fits
- The cost of a second store
- Caches and locks
- Search indexes
- Designing in the other models
- Sources

## Default

- Start relational: one database, one transaction model and one backup to restore.
- Spend a new store as a scarce innovation token, not by default.
- Use the relational engine's own features first: JSON columns for semi-structured data, full-text search for simple search, a database-backed queue and cache.
- Check the framework: many now ship a queue, cache and pub-sub on the main database.

## The kinds of store

| Kind | Fits | Does not fit |
|---|---|---|
| Relational | Many relations, ad hoc queries, reports, rules across records | Nothing it cannot do at the required scale; try it first |
| Document | A self-contained record read and written whole, with a varying shape | Many joins across records |
| Key-value | A cache, counters, rate limits, session data, short-lived locks, rankings, at memory speed | The only copy of business records |
| Wide-column | Known, stable access patterns at a write volume or size past one server | Ad hoc queries |
| Search index | Relevance-ranked text search, facets, fuzzy matching, log analysis | The source of truth |

## When a second store fits

- Name the access pattern the relational database cannot serve, and measure it first.
- Choose a document store when the record is an aggregate read whole and few queries join across aggregates.
- Choose a key-value store for data that can be rebuilt and is read at memory speed.
- Choose a wide-column store when the queries are known and stable and the volume is past one server.
- Choose a search index for relevance and facets after the relational engine's full-text search falls short.
- Stay relational when the data has many relations or rules that span records. Those need joins and constraints.

## The cost of a second store

- Count the operational cost: each store needs its own deploy, monitoring, upgrades, backups and restore drills.
- Expect no transaction across stores. A write to the database and a write to the second store can disagree after a crash.
- Keep a derived store in step with a transactional outbox or change data capture, and make the consumer idempotent.
- Design the derived store so it can be dropped and rebuilt from the source of truth.
- Name which store is the source of truth for each fact, in writing. Every other copy is a cache or an index.

## Caches and locks

- Make every cached value rebuildable from the database. A cold or flushed cache must only slow the application down.
- Give every cache key an expiry when it is written, and set a memory limit and an eviction policy on every cache.
- Keep cache keys and keys that must persist in separate instances, because eviction treats them alike.
- Expect a queued group of commands in a key-value store to have no rollback: a failing command does not undo the others. Use a server-side script for a read-modify-write.
- Treat a lock in a key-value store as advisory. Replication is asynchronous, so a failover can grant the same lock twice. Use fencing tokens when correctness depends on the lock.
- Prefer a database lock when the protected data lives in that database.

## Search indexes

- Treat the index as derived data, rebuilt from the source of truth.
- Define explicit mappings in production. Guessed types can explode the field count.
- Expect a field's mapping to be fixed once set. Changing it means a new index and a reindex.
- Query through an alias, build the new index beside the old one, then switch the alias.
- Expect near real-time search: a write becomes searchable after the next refresh.
- Feed the index from the database through an outbox or change data capture, with idempotent upserts keyed by the source row id.

## Design in the other models

- Document: store together what is read together. Embed what belongs to a parent. Reference what is shared or unbounded. Never let an array grow without a bound. Switch on schema validation, and design so one business write changes one document.
- Wide-column: list the queries first, then design one table or key per query. Spread writes across partitions and keep partitions bounded.
- Key-value: name keys with one scheme, pick the structure that does the work on the server, and never scan the whole keyspace on a production server.
- Check the engine's documentation for each model's limits, such as maximum record size and write throughput per partition.

## Sources

- Martin Fowler, "PolyglotPersistence" (2011): https://martinfowler.com/bliki/PolyglotPersistence.html
- Pramod Sadalage and Martin Fowler, *NoSQL Distilled* (Addison-Wesley, 2012).
- Dan McKinley, "Choose Boring Technology" (2015): https://mcfunley.com/choose-boring-technology
- Martin Kleppmann, *Designing Data-Intensive Applications* (O'Reilly, 2017), chapters 2, 11 and 12.
- Martin Kleppmann, "How to do distributed locking" (2016): https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html
- Chris Richardson, Transactional outbox: https://microservices.io/patterns/data/transactional-outbox.html
