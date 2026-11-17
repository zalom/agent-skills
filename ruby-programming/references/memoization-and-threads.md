# Memoization and threads

Proof script: `scripts/18_memoization_threads.rb`.

- **`@value ||= work` runs the work again on every read when the answer is `nil` or `false`.** Guard with `defined?`:

```ruby
def feature_enabled?
  return @feature_enabled if defined?(@feature_enabled)

  @feature_enabled = expensive_check
end
```

- **Memoization is not thread safe.** Four concurrent readers ran the work four times in the proof script. When the work must run once, compute the value before the threads start, or guard it with a `Mutex`.
- **`freeze` does not make an object thread safe.** A frozen `Hash` whose value is a mutable `Array` still takes writes from two threads. Freeze the values as well, or use `Ractor.make_shareable`.
- **`Ractor.new(object)` copies an object that is not shareable.** The caller's object stays untouched, so a change made inside the Ractor is lost.
