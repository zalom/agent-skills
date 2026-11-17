# Ruby design fixes

Each fix removes the cause. Silencing a smell in `.reek.yml` or a todo file leaves the cause in place.

## Reek smells and their design fix

| Smell | What it says | Fix |
|---|---|---|
| FeatureEnvy | The method uses another object's data more than its own | Move the method to the object whose data it uses |
| UtilityFunction | The method uses no state of its object | Move it to the object it works on, or make it a pure module function of a value object |
| DataClump | The same parameters travel together | Make them one `Data.define` value and pass that |
| ControlParameter | A flag picks the method's path | Split into two methods, or pass the role object that does the variant |
| DuplicateMethodCall | The same call repeats in one method | Name the result once with a local or a method; when it repeats across methods, the object is missing a query |
| NestedIterators | A loop inside a loop | Use one pipeline (`flat_map`, `group_by`, `to_h`), move the inner loop into a method of the element, or let SQL do it |
| TooManyMethods, TooManyInstanceVariables, TooManyConstants | The class does several jobs | Extract each job into its own object, named after it |
| UncommunicativeModuleName | The name carries a number or no meaning | Rename after what it does (`MoveIntentsToKnowledge`, not `SchemaStore4`) |
| LongParameterList | Positional coupling | Keyword arguments, or one value object |

## A require cycle

1. Run `ruby -w -e 'require "./lib/name"'` and read the "circular require considered harmful" lines.
2. Find what the lower file takes from the higher one. Usually it is an error class, a constant or a value type.
3. Move that into the lower layer, or into a small kernel file that requires nothing above it.
4. When the lower file must call up, pass the higher object in as a role.
5. The top file (`lib/name.rb`) only requires the layers in order. It defines nothing the layers use.

## A class-level singleton

```ruby
# Hidden global: one connection for the whole process, and tests share it.
class Store
  def self.save(row) = (@db ||= SQLite3::Database.new(PATH)).execute(SQL, row)
end

# An instance that receives its collaborator.
class Store
  def initialize(database:) = @database = database
  def save(row) = @database.execute(SQL, row)
end
```

## A global clock

Pass `clock:` (or `now:`) into the object that stamps time, with the production default, and pass it down from the entry point. A module method such as `Plastic.now` that every layer calls is a global input: tests then stub it or read the real clock.

## A row loop between SQLite files

```ruby
# Ruby objects per row, a digest compare, a drop: many lines, many failure points.
source.execute("SELECT * FROM intents").each { |row| target.execute(INSERT, row) }

# One statement on one connection, atomic in rollback journal mode.
connection.execute("ATTACH DATABASE ? AS knowledge", [knowledge_path])
connection.transaction(:immediate) do
  connection.execute("INSERT INTO knowledge.intents SELECT * FROM main.intents")
  connection.execute("DROP TABLE main.intents")
end
```

`ATTACH` must run before `BEGIN`: SQLite refuses it inside a transaction.

## Code only tests call

Delete the method and the tests that call it. When the tests stood in for a real check, move the check to where production runs it (a startup check, a doctor check) or into the guard file with the other repository checks.

## Sources

The design and testing research of 2026-11-17: Sandi Metz, Jim Weirich, Kent Beck, Gary Bernhardt, Avdi Grimm, Martin Fowler, Reek's smell documentation, and the code of Sequel, Rake, Minitest, Hanami and Rack.
