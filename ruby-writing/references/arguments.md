# Arguments and delegation

Proof script: `scripts/10_kwargs_delegation.rb`.

## Forward with `...`

```ruby
# wrong on Ruby 3 and newer: keyword arguments arrive as one Hash
def delegate(*args, &block)
  target(*args, &block)
end

# right
def delegate(...)
  target(...)
end
```

The anonymous form `def delegate(*, **, &)` with `target(*, **, &)` also works. `Style/ArgumentsForwarding` asks for the modern form in RuboCop as a style point. Standard turns it off. Neither says that the old form loses keywords.

## Smaller traps

- **`**nil` declares that a method takes no keywords.** Use it on a method that takes one positional `Hash`. A caller's keyword typo then raises `ArgumentError: no keywords accepted`. Without it, the typo becomes that `Hash`.
- **A `Hash` passed positionally stays positional in Ruby 3.** `kw({b: 1})` does not fill the keyword `b`.
- **A `proc` is lenient about the argument count and splats an array. A `lambda` is strict.** Use a `lambda` when the count matters.
- **`return` inside a `proc` returns from the enclosing method.** Inside a `lambda` it returns from the lambda.
- **A default value that is a constant is shared across calls.** `def add(item, list = SHARED)` grows `SHARED`. A literal default, `list = []`, is fresh on each call.
