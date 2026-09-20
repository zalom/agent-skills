# Strings, encoding, and collections

Proof scripts: `scripts/04_unary_plus_precedence.rb`, `scripts/17_strings_collections.rb`.

- **`+"text".sub!(...)` parses as `+("text".sub!(...))`.** Under `# frozen_string_literal: true` the bang method runs on the frozen literal and raises `FrozenError`. Write `(+"text").sub!(...)`, or use `String.new`.
- **`Array#-` and `Array#|` are set operations.** `left.chars - right.chars` removes every copy of a shared character. It is not a count of differences: every anagram scores zero. For "did the user mean this command", use `DidYouMean::SpellChecker.new(dictionary: names).correct(typed)` from the standard library.
- **`Hash.new([])` shares one array across every missing key and stores nothing.** Write `Hash.new { |hash, key| hash[key] = [] }`.
- **`sort` and `sort_by` are not stable.** The documentation says that the order of equal elements "may be unstable". When the order among equals matters, sort by `[key, index]`.
- **`to_i` never fails. `Integer()` does.** `"12abc".to_i` is 12 and `nil.to_i` is 0. `Integer("12abc")` raises. `Integer("08")` also raises, because a leading zero means octal; write `Integer("08", 10)`. Use `Integer()` for input that must be a number.
- **`split` drops trailing empty fields.** `"a,b,,".split(",")` gives two fields. `split(",", -1)` keeps all four.
- **`ljust` counts characters, not display columns.** A table built with `ljust` goes out of line for a wide character such as `日`, and for an accent stored as two code points. When every label is ASCII, write that limit down in a test. Add a display-width gem only when a label needs it.
- **Bytes from a file or the environment can be invalid UTF-8.** A match with `=~` on such a string raises `ArgumentError`. Call `scrub` before matching.
- **A string literal with interpolation is never frozen,** even under `# frozen_string_literal: true`. `+string` returns the same object when it is already mutable; `dup` always copies.
