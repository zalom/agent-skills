# Metaprogramming

Proof script: `scripts/09_metaprogramming.rb`.

Reach for these tools last. Plain methods and plain objects are easier to change.

- **`method_missing` needs `respond_to_missing?`.** Without it, `respond_to?`, `method`, and `&:name` all fail for the ghost method. `Style/MissingRespondToMissing` catches this in RuboCop and in Standard.
- **Wrap a method with `prepend` and `super`, never an alias chain.** An alias chain wraps twice when the file loads twice, and the second wrap recurses until `SystemStackError`. `include` does not help, because the class's own method wins over an included module.
- **`define_method` closes over the loop variable. `def` does not see it.** Use `define_method` when the body needs a value from the surrounding loop.
- **`return` inside a `define_method` block returns from the defined method,** not from the block only. It behaves like a method body.
- **Keep `refine` out of application code.** A refinement applies only in the file that says `using`, and `send` and `respond_to?` do not see it.

```ruby
module Logged
  def work
    "logged(#{super})"
  end
end

class Worker
  prepend Logged

  def work
    "work"
  end
end
```
