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
| UncommunicativeModuleName | The name carries a number or no meaning | Rename after what it does (`AddEmailToUsers`, not `Migration4`) |
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
  def self.save(row) = (@db ||= Database.connect(URL)).execute(SQL, row)
end

# An instance that receives its collaborator.
class Store
  def initialize(database:) = @database = database
  def save(row) = @database.execute(SQL, row)
end
```

## A global clock

Pass `clock:` (or `now:`) into the object that stamps time, with the production default, and pass it down from the entry point. A module method such as `App.now` that every layer calls is a global input: tests then stub it or read the real clock.

## A row loop in Ruby

```ruby
# One object and one write per row: slow, and a crash leaves half the rows changed.
User.where(trial_ended: true).find_each { |user| user.update!(plan: "free") }

# One statement, one transaction, done by the database.
User.where(trial_ended: true).update_all(plan: "free")
```

The same holds without an ORM: send one `UPDATE` or `INSERT ... SELECT`, not a loop of single-row statements. The `database-designing` skill has the rules for moving data.

## Code only tests call

Delete the method and the tests that call it. When the tests stood in for a real check, move the check to where production runs it (a startup check, a doctor check) or into the guard file with the other repository checks.

## Sources

Sandi Metz, Jim Weirich, Kent Beck, Gary Bernhardt, Avdi Grimm, Martin Fowler, Reek's smell documentation, and the code of Sequel, Rake, Minitest, Hanami and Rack.
