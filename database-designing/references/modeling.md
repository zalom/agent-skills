# Modeling

Rules for any relational engine. Where a rule needs an engine feature, check the engine's documentation for it.

## Contents

- Keys
- Normalization
- Constraints
- Types
- Naming
- Nulls
- Enum-like values
- Time
- Antipatterns and their fixes
- Sources

## Keys

- Give every table a primary key.
- Use a surrogate key when the natural key is long, mutable or composite across many child tables.
- Put a unique constraint on the natural key even when a surrogate key exists. The surrogate alone lets duplicates in.
- Use the compound key itself for an intersection table. An extra id adds nothing.
- Never renumber keys to close gaps. A key identifies a row, it does not count rows.
- Prefer short, increasing keys on engines that cluster rows by primary key. Check the engine's documentation for how it stores them.
- Use a random identifier only when keys must be made outside the database. Random keys scatter inserts across a clustered index.

## Normalization

- Normalize to third normal form: every non-key column depends on the key, the whole key and nothing but the key.
- Stop when each fact is stored once. Splitting further only adds joins.
- Denormalize only for a read path that was measured. Keep the copy correct with a constraint, a generated column or a trigger in the same transaction.
- Store a derived value as a generated column, not as a column the application keeps in step.

## Constraints

- Declare not-null on every column that must have a value. It is the cheapest constraint there is.
- Encode value rules as check constraints so every writer obeys them, not only the application.
- Declare every reference as a foreign key. Application-only references rot.
- Index the child columns of each foreign key. A delete or update of the parent scans the child otherwise.
- Enforce uniqueness with a unique constraint, never with a select before an insert. Two writers both pass the select.
- Name constraints so an error message says what was broken.
- Check that the engine enforces each constraint. Some engines ship with foreign keys or checks off or ignored.

```sql
ALTER TABLE orders ADD CONSTRAINT orders_total_not_negative
  CHECK (total_cents >= 0);
```

## Types

- Store money as an exact decimal or as integer minor units, never as a floating-point number.
- Use the narrowest type that holds every valid value, and a check for the rest, rather than an arbitrary length limit.
- Use the engine's boolean and date-time types. Where it has none, add a check that pins the stored form.
- Use a JSON column only for data the database never needs to constrain or join on.

## Naming

- Name a table for what one row holds. Use one convention, plural or singular, across the whole schema.
- Write names in lower case snake_case.
- Name a foreign key column `<referenced_singular>_id` and a time column `<event>_at`.
- Name an index by table and columns (`index_orders_on_customer_id`) so a plan shows what it covers.
- Never name a column after its type or position (`data`, `value2`, `field1`).

## Nulls

- Treat null as unknown. Test it with `IS NULL`, `IS DISTINCT FROM` or `COALESCE`, where equality would hide rows.
- Use `NOT EXISTS`, never `NOT IN`, against a subquery that can return null. One null makes `NOT IN` return no rows.
- Avoid a nullable column whose null means two different things. Give each state its own column.
- Know that a unique constraint usually allows many nulls. Check the engine's documentation for how to change that.

## Enum-like values

- Use a check with a fixed list when the values change only with a code release.
- Use a lookup table with a foreign key when users or operators add values.
- Avoid native enum types where removing or reordering a value needs a rewrite.

```sql
status TEXT NOT NULL DEFAULT 'pending'
  CHECK (status IN ('pending', 'paid', 'shipped'))
```

## Time

- Store points in time as UTC, in a type that knows it is UTC where the engine has one.
- Convert to local time only for display.
- Query time ranges as half-open (`>= start AND < end`), never with `BETWEEN`.

## Antipatterns and their fixes

- A comma-separated list in one column (Jaywalking): make an intersection table.
- A parent id with one query per level (Naive Trees): use a recursive query, or a closure table when reads of whole subtrees dominate.
- An id on every table by habit (ID Required): use the natural or compound key where it fits, with a unique constraint on the natural key.
- No foreign keys (Keyless Entry): declare them. The database then checks every writer.
- A table of name and value rows (Entity-Attribute-Value): one column per attribute. Use table inheritance for subtypes and a JSON column for truly open data.
- A type column and an id column that point at any table (Polymorphic Associations): one foreign key per parent with a check that exactly one is set, or one intersection table per parent, or a common super-table.
- `tag1`, `tag2`, `tag3` (Multicolumn Attributes): a dependent table with one row per value.
- A table per year or per tenant (Metadata Tribbles): one table with the year or tenant as a column. Use partitioning when size demands it.
- Floating point for exact values (Rounding Errors): exact decimals or integer minor units.
- Indexes by guess, or none (Index Shotgun): measure, explain, nominate, test, optimize, rebuild.
- File paths with no lifecycle in the database (Phantom Files): store the bytes in the database, or make the file's lifecycle part of the design. The database cannot roll a file back.
- Non-grouped columns in a grouped query (Ambiguous Groups): use a window function or join to the grouped result.
- Random order over a big table (Random Selection): pick a random key in a cheap query, then fetch by key.
- A leading-wildcard `LIKE` for search (Poor Man's Search Engine): use the engine's full-text index, or a search store.
- `SELECT *` and an insert without a column list (Implicit Columns): name the columns.
- A password stored readable (Readable Passwords): store a salted slow hash.
- SQL built by joining strings with input (SQL Injection): bind parameters.
- Business logic in stored procedures that no test or deploy reaches: keep logic in versioned code. Constraints declare facts, procedures hide behavior.

## Sources

- Bill Karwin, *SQL Antipatterns, Volume 1* (Pragmatic Bookshelf, 2022): every antipattern named above.
- C. J. Date, *Database Design and Relational Theory*, 2nd ed. (Apress, 2019). William Kent, "A Simple Guide to Five Normal Forms" (CACM, 1983).
- Joe Celko, *SQL Programming Style* (Morgan Kaufmann, 2005).
- Markus Winand, Use the Index, Luke: https://use-the-index-luke.com
