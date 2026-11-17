# Command-line options with `OptionParser`

Proof script: `scripts/16_optionparser.rb`.

- **Long options can be shortened by default.** `--js` matches `--json` today. Adding `--jsonl` later makes `--js` raise `OptionParser::AmbiguousOption`, and every script that a user wrote with the short form breaks. Decide on purpose whether to keep this, and test the choice.
- **`parse!` changes the argument array in place and returns the same object.** Pass a copy when the caller still needs the original.
- **`parse!` scans every argument. `order!` stops at the first one that is not an option.** For a program with subcommands, use `order!`, so the parent does not take a flag that belongs to the subcommand. The environment variable `POSIXLY_CORRECT` makes `parse!` behave like `order!`.
- **An error raised inside an `on` block leaves `parse!` unwrapped.** A `rescue OptionParser::ParseError` does not catch an `ArgumentError` from the block. Raise `OptionParser::InvalidArgument` inside the block.
- **`on("--json")` yields `true`, not a string. `on("--[no-]json")` yields `false` for `--no-json`.**

```
order!: opts={} argv=["sub", "--json"]
parse!: opts={json: true} argv=["sub"]
```
