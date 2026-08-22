# Overrides, example

Copy this file to turn on the personal layer:

```sh
cp references/overrides.example.md references/overrides.md
```

How the layer works:

- It is optional. Without `references/overrides.md`, the Google layer under `references/google/` applies on its own.
- When the file exists, the agent reads it first on every activation, and every line in it wins over the Google layer.
- It is personal. `references/overrides.md` is listed in `.gitignore`, so it is never committed and an update to this repository never overwrites it.
- Write one rule per line, in your own words. State the rule, not the reason for it.

Replace these instructions with your own rules.
