# Objects, values, and equality

Proof scripts: `scripts/08_struct_data_equality.rb`, `scripts/13_constants_and_load.rb`.

## Define `==`, `eql?`, and `hash` together

`Array#include?` uses `==`, so a class with only `==` looks right in a quick check. `Hash` lookup and `Set` membership use `hash` and then `eql?`, and they fail without an error. No linter catches this.

```ruby
def ==(other)
  other.instance_of?(self.class) && value == other.value
end
alias_method :eql?, :==

def hash
  [self.class, value].hash
end
```

`Comparable` gives `==` from `<=>`. It does not give `hash`, so the same fault applies.

## `Data` over `Struct` for a value object

| | `Struct.new(:x, :y)` | `Data.define(:x, :y)` |
|---|---|---|
| Missing member | `nil`, with no error | `ArgumentError: missing keyword: :y` |
| Frozen | No | Yes |
| Keyword arguments | Only with `keyword_init: true` | Always, and positional too |
| Copy with a change | None | `with` |
| `to_a` and `[]=` | Yes | No |

`Data` is available from Ruby 3.2. A `Struct` that changes while it is a `Hash` key falls out of its bucket: `hash[key]` returns `nil` until `rehash`. `Data` is frozen, so it cannot do this.

## `<=>` returns `nil` for a value it cannot compare

Return `nil`, never raise. `Comparable` then raises the right `ArgumentError: comparison of Version with 2 failed`.

## `freeze` is shallow

A frozen `Hash` with an `Array` value still lets the array grow. `Style/MutableConstant` catches an unfrozen literal constant, not a nested value. Freeze the inner values, or build the constant from `Data` objects.
