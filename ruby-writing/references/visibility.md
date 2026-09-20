# Visibility

Proof scripts: `scripts/05_visibility.rb`, `scripts/15_protected_override.rb`.

## `private` is right whenever the call is on `self`

Since Ruby 2.7, `private` allows an explicit `self.` receiver for readers and writers. A subclass can call and override a private method. The only thing that `protected` adds is a call on another object of the same class.

```ruby
# needs protected: the receiver is another object
def richer_than?(other)
  balance > other.balance
end

# needs only private: the receiver is self
def report
  "#{balance} cents"
end
```

`send` reaches private and protected methods alike, so neither is a security boundary. No linter decides between the two.

## A subclass that redefines a protected method breaks the parent

Ruby issue 13804, "Protected methods cannot be overridden", is open. When a subclass defines the method again, the access check moves to the subclass, and an instance of the parent can no longer call it. On Ruby 4.0.3:

```
Person   vs Person     -> true
Person   vs Employee   -> NoMethodError: protected method 'ssn' called for an instance of Employee
Employee vs Person     -> true
Employee vs Employee   -> true
```

The fault is one-sided. A test that exercises only the subclass passes. When a comparison needs `protected`, test the parent against the subclass as well.

## A plain `def` in a subclass is public

Visibility belongs to each definition. When the base class declares a private hook, a subclass that writes a plain `def call` makes `call` public on that subclass. Write `private` above the hook in the subclass too.

```ruby
class Status < Command
  private

  def call
    # ...
  end
end
```

## Constants

- `private_constant :SECRET` hides a constant from outside the class. `freeze` does not hide anything.
- `private def name` works, because `def` returns the method name as a symbol. `Style/AccessModifierDeclarations` asks for the grouped form in RuboCop. Standard turns that rule off. Follow the file's existing style.
- `Lint/IneffectiveAccessModifier` catches `private` written above `def self.name`, where it has no effect. Use `private_class_method` there.
