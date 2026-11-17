# Exceptions, rescue, and control flow

Proof scripts: `scripts/01_exceptions.rb`, `scripts/02_undeclared_hook_vcall.rb`, `scripts/03_and_or_precedence.rb`, `scripts/06_ensure_and_return.rb`, `scripts/07_raise_forms.rb`.

## Contents

- An abstract hook raises `NoMethodError`
- An undeclared hook raises `NameError`
- `and` and `or` never produce a value
- `return` in `ensure` swallows the exception
- A method-level `rescue` does not cover default arguments
- A custom error calls `super` with its message
- Rescue `StandardError`, never `Exception`
- `raise`, `fail`, and `cause`
- `Timeout::Error` is a `StandardError`

## An abstract hook raises `NoMethodError`

`NotImplementedError` descends from `ScriptError`, not from `StandardError`. A bare `rescue`, a `rescue => e`, and a one-line `rescue` modifier all catch `StandardError` only. An abstract method that raises `NotImplementedError` passes every ordinary error boundary. Ruby's documentation says the class is "Raised when a feature is not implemented on the current platform". No linter flags this.

```ruby
# wrong
def call
  raise NotImplementedError, "subclass must implement"
end

# right
def call
  raise NoMethodError, "#{self.class} must define call"
end
```

## An undeclared hook raises `NameError`

A bare `call`, with no receiver and no parentheses, can be a local variable or a method. When nothing defines it, Ruby raises `NameError`. `NoMethodError` is a subclass of `NameError`, so a caller that writes `rescue NoMethodError` catches nothing. Declare the hook in the base class. The declaration fixes the error class and the message, and it shows the contract to the reader.

```ruby
# wrong: the base class calls a hook that it never declares
class Command
  def run
    call
  end
end

# right
class Command
  def run
    call
  end

  private

  def call
    raise NoMethodError, "#{self.class} must define call"
  end
end
```

The same holds for a constant that the base class reads, such as `self.class::USAGE_LINE`. Cover it with one test that checks every subclass defines the constant.

## `and` and `or` never produce a value

`and` returns its left side when that side is falsey. `IO#puts` returns `nil`, `Hash#delete` returns `nil` for a missing key, and every `sub!` or `reject!` returns `nil` when nothing changed. `and` also binds looser than `=`, so `y = a and b` assigns `a` to `y`.

```ruby
# wrong: the exit code depends on what usage returns
def report
  @output.usage(message) and USAGE
end

# right
def report
  @output.usage(message)
  USAGE
end
```

The Ruby Style Guide allows only the control-flow forms: `x = extract or raise ArgumentError, "missing"` and `user.suspended? and return :denied`. The RuboCop rule `Style/AndOr` catches the value form only with `EnforcedStyle: always`. The default, `conditionals`, stays silent, and Rails Omakase turns the rule off.

## `return` in `ensure` swallows the exception

Never put `return`, `break`, or `next` in an `ensure`. It discards the return value and any exception in flight. `Lint/EnsureReturn` catches this, in RuboCop and in Standard.

## A method-level `rescue` does not cover default arguments

The `rescue` of a method starts after its parameters are bound. An error raised while a default value is computed escapes the method. Keep work that can raise out of default values.

## A custom error calls `super` with its message

```ruby
# wrong: the message is the class name, "Broken"
class Broken < StandardError
  def initialize(detail)
    @detail = detail
  end
end

# right
class Fixed < StandardError
  def initialize(detail)
    @detail = detail
    super("failed on #{detail}")
  end
end
```

`Lint/MissingSuper` catches this in RuboCop. Standard turns that rule off.

## Rescue `StandardError`, never `Exception`

`rescue Exception` also catches `Interrupt`, `SignalException`, `SystemExit`, and `NoMemoryError`. A bare `rescue` already means `StandardError`. `Lint/RescueException` catches this. A `rescue` clause that names a value that is not a class raises `TypeError` and hides the real error; `Lint/RescueType` catches that.

## `raise`, `fail`, and `cause`

- Write `raise`, never `fail`. The Ruby Style Guide says "Prefer raise over fail for exceptions", and `Style/SignalException` defaults to `only_raise`.
- A bare `raise` inside a `rescue` raises the current error again. Outside a `rescue` it raises an empty `RuntimeError`.
- Ruby sets `cause` on its own when an error is raised inside a `rescue`. Pass `cause:` only when raising outside the original `rescue`.

## `Timeout::Error` is a `StandardError`

Every bare `rescue` inside a `Timeout.timeout` block catches the timeout. The timeout is raised inside whatever line runs at that moment, also inside an `ensure`. Pass a custom error class to `Timeout.timeout`, or make sure that no inner `rescue => e` catches the timeout.
