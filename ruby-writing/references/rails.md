# Rails code

## Which method to use

1. **The 37signals method first, always.** Vanilla Rails, rich models, thin controllers, concerns named for a capability, Minitest, and no service objects by default. When a `37signals-style` skill is installed, use it for every Rails decision.
2. **The Rails guides for facts.** When a question is about what a Rails version does, read the guide for that version, or a `rails-guides` skill or a Rails documentation server when one is present. Never answer a version question from memory.
3. **Another method only when and if needed.** Layered design comes second, and the next section covers it. Layered design, service objects, form objects, and RSpec-based approaches come in only when the project's own instructions name them, or when the owner asks. Never bring one in because a class grew. The 37signals answer to a large model is a concern, or a plain object that the model delegates to.

Jorge Manrubia of 37signals, in "Vanilla Rails is plenty": "we don't default to create services, actions, commands, or interactors to implement controller actions." And: "We are fine with plain CRUD accesses from controllers for simple scenarios."

## The second choice: layered design

When a project asks for layers, use the `layered-rails` skill from `palkan/layered-rails-skills`. It follows the book "Layered Design for Ruby on Rails Applications" by Vladimir Dementyev. Install it in that project only, never for every project:

```
npx skills add palkan/layered-rails-skills --skill layered-rails
```

The repository has no `LICENSE` file. Its README, its gemspec and its `plugin.json` each declare MIT. A vendored copy carries a provenance note that names the repository, the commit, the date and those three places.

It conflicts with the 37signals method in five places. In a project that has not chosen layers, the 37signals side wins each time.

- **Services are a layer of their own.** The skill routes an operation that spans several models to a service object. Vanilla Rails has no `app/services`.
- **Its base service needs `Dry::Initializer`.** That is a gem outside the standard library and outside Rails.
- **It assumes RSpec and factories.** The 37signals method uses Minitest and fixtures.
- **It names a stack of 10 gems,** among them `action_policy`, `view_component` and `alba`. Add one only when the project already uses it.
- **It adds an Archspec check in CI** that enforces layer boundaries. Without layers, that check has nothing to enforce.

Six of its rules are safe under the 37signals method, as review questions:

- **The specification test.** The skill: "If the specification of an object describes features beyond the primary responsibility of its abstraction layer, such features should be extracted into lower layers."
- **The callback scores.** A callback that transforms or normalizes its own record stays. A callback that runs an operation moves to a method with a name.
- **The concern test.** The skill: "If removing this concern breaks unrelated tests, it's code-slicing."
- **The order of a model file,** from the gem DSL calls at the top to the private methods at the bottom.
- **Models never read `Current` attributes.** Pass the value in.
- **Let code age before extracting.** The skill: "premature abstraction is worse than duplication."

## Traps that the Rails guides document

Nothing on this page was run. Each rule quotes the guide, read on 2026-09-20.

- **Work that touches another system goes in `after_commit`, never in `after_save`.** That includes enqueuing a job. The guide: "during after_commit the data was already persisted to the database, and thus any exception won't roll anything back anymore." Work that must be able to stop the save goes in `after_save`.
- **One `after_commit` that raises cancels the rest.** The guide: "the exception will bubble up and any remaining after_commit or after_rollback methods will not be executed."
- **`validates uniqueness` needs a unique index.** The guide: "This validation does not create a uniqueness constraint in the database". Add `add_index ..., unique: true` in the same change, on both columns for a scoped validation. The rule `Rails/UniqueValidationWithoutIndex` in `rubocop-rails` catches a missing index.
- **Seven methods skip validations:** `increment!`, `toggle!`, `update_attribute`, `update_attribute!`, `update_column`, `update_columns`, and `save(validate: false)`. `Rails/SkipsModelValidations` flags them.
- **`find_each` ignores an `order`.** Records come in primary key order, and by default the given order is dropped with a warning only.
- **`pluck` runs the query at once and returns arrays.** It cannot be chained, and model method overrides do not apply to the values.
- **`enum` raises `ArgumentError` for an unknown value,** before validation runs. A form or an API that can receive a bad value needs `validate: true`.
- **Use `dependent: :delete_all` when the children have no callbacks.** `:destroy` loads each row and runs its callbacks; `:delete_all` sends one statement.
- **Keep callbacks for setup and cleanup.** Business logic goes in a method with a name that the controller or the job calls.
