# Ruby 3.4 and 4.0: old advice that is now wrong

Proof script: `scripts/14_ruby4_and_modern.rb`, run on Ruby 4.0.3.

| Old advice | State today |
|---|---|
| "Use `fail` for a first raise and `raise` to raise again" | The Ruby Style Guide says "Prefer raise over fail for exceptions". `Style/SignalException` defaults to `only_raise`. Write `raise`. |
| "`_1` is the block parameter" | `it` works since Ruby 3.4 and reads better. A local variable named `it` shadows it. |
| "`{a: 1}.inspect` prints `{:a=>1}`" | Since Ruby 3.4 it prints `{a: 1, "b" => 2}`. A test that compares against the old text fails. Compare values, not `inspect` output. |
| "`ostruct`, `logger`, `benchmark`, `csv`, `base64`, `observer`, `rexml`, `fiddle`, and `mutex_m` come with Ruby" | They are bundled gems now. `require` still works outside Bundler. Under Bundler they must be in the `Gemfile`. |
| "`SortedSet`, `Fixnum`, `File.exists?`, and `Object#taint` exist" | All are gone. `Set` needs no `require`. `ENV.freeze` raises `TypeError`. |
| "An endless method cannot call a command with arguments" | `def show = puts "x", "y"` parses on Ruby 4.0. A setter method still cannot be endless. |
| "`case/in` works like `case/when`" | `case/in` with no match raises `NoMatchingPatternError`; `case/when` returns `nil`. `hash => pattern` raises on a mismatch; `hash in pattern` returns true or false. |

For a change of the interpreter version itself, use a Ruby upgrade procedure. This page covers only what changes in the code that gets written.
