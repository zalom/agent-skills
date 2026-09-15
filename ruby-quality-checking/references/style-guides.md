# Style guides

How `scripts/setup-project` and `bin/verify-change` detect and run a project's style guide. Open this when adding a lint step, choosing a style guide for a new project, or figuring out why a project's style guide reads as ambiguous.

## Contents

- Detection
- Detection matrix
- Installing one
- The lint command
- Ambiguous style guides
- Sources

## Detection

`ProjectProfile#style_guide` returns one of:

- `:omakase` - `rubocop-rails-omakase` declared (Gemfile, Gemfile.lock DEPENDENCIES, or a gemspec), or `.rubocop.yml` has `inherit_gem: { rubocop-rails-omakase: ... }`.
- `:standard` - `standard` declared, `.standard.yml` exists, or `.rubocop.yml` wires Standard in (`inherit_gem: { standard: ... }`, or `standard` under a `plugins:`/`require:` list, flow or block form).
- `:rubocop` - `rubocop` declared, or `.rubocop.yml` exists with none of the above.
- `:ambiguous` - both `.standard.yml` and a `.rubocop.yml` exist, and the `.rubocop.yml` does not wire in Standard.
- `nil` - none of the above.

`:ambiguous` and no style guide are never a `missing` gap on their own terms; the gap this skill reports is "a style guide", offered as a choice, never installed unasked.

## Detection matrix

Measured 2026-09-14, RuboCop 1.91.0 and standard 1.56.0:

| Setup | Gemfile line | Config file | `Gemfile.lock` DEPENDENCIES |
|---|---|---|---|
| Rails default (omakase) | `gem "rubocop-rails-omakase", require: false` | `inherit_gem: { rubocop-rails-omakase: rubocop.yml }` | `rubocop-rails-omakase` present, bare `rubocop`/`standard` absent |
| `standard` alone | `gem "standard"` | `.standard.yml` present, no `.rubocop.yml` | `standard` present, bare `rubocop` absent from DEPENDENCIES |
| RuboCop + standard plugin | `gem "rubocop"` and `gem "standard"` | `.rubocop.yml` with both `require: [standard]` (or `require: standard`) and `inherit_gem: { standard: config/base.yml }`; a bare `plugins: standard` fails to load on standard 1.56.0 with RuboCop 1.88-1.91 | both `rubocop` and `standard` present; standard 1.56.0 requires `rubocop ~> 1.88.0`, not 1.91 |
| Plain RuboCop | `gem "rubocop"` only | `.rubocop.yml` with no Standard or omakase wiring | only `rubocop` present |
| `rubocop-rails-omakase` added by hand, non-Rails | `gem "rubocop-rails-omakase"` | identical to the Rails-generated case | identical to a real Rails app's DEPENDENCIES; only a Rails marker file (`config/application.rb`, `bin/rails`) tells them apart |

`rubocop --force-exclusion FILES` and `standardrb --force-exclusion FILES` both skip a file
passed on the command line that is also listed in the config's exclude/ignore list.

## Installing one

`setup-project --linter omakase|standard|rubocop`:

- With no style guide, installs the named one: the gem line in the Gemfile, and a minimal `.rubocop.yml` or `.standard.yml`.
- With a style guide already set up that matches, prints `kept` and changes nothing.
- With a different style guide already set up, warns and keeps the existing one.
- On an ambiguous project, warns and installs nothing.
- Under `--dry-run`, prints what would change and writes nothing.

With no `--linter` and no style guide, `setup-project` prints the 3 choices and installs none of them.

## The lint command

`bin/verify-change` picks the command from the config file, not from the abstract style guide symbol above, because a `.rubocop.yml` that loads Standard still needs `rubocop`, not `standardrb`, to read it:

- `.rubocop.yml` present (whether or not it wires in Standard) → `bundle exec rubocop --force-exclusion FILES`.
- No `.rubocop.yml`, and `.standard.yml` or `standard` under DEPENDENCIES → `bundle exec standardrb --force-exclusion FILES`.
- Both `.standard.yml` and an unrelated `.rubocop.yml` → skipped, ambiguous.
- The chosen command's gem is missing from `Gemfile.lock` → skipped, names the gem.
- Neither file nor gem → skipped, no style guide.

A skip is never a failure. A lint failure is reported under `Failed:` but does not stop patch coverage, mutation testing, or CRAP.

## Ambiguous style guides

Two style guide files with no wiring between them is a project in the middle of a migration, or a merge that kept both. Neither script picks one:

1. Decide which style guide the project keeps.
2. Delete the other's config file and gem line by hand.
3. Run `setup-project --linter` again to confirm it reads clean.

## Sources

- [Standard: usage with RuboCop](https://github.com/standardrb/standard#can-i-use-standard-alongside-rubocop)
- [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase)
- [RuboCop configuration](https://docs.rubocop.org/rubocop/configuration.html)
