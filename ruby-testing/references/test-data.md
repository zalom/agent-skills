# Test data

Fixtures and factories, and how to write tests in a project that has one, the other, or both. Open this when adding a test that needs data, or choosing between fixtures and factories for a new project.

## Contents

- Fixtures
- Factories
- A project with both
- Choosing for a new project
- Sources

## Fixtures

Static YAML files under `test/fixtures/` or `spec/fixtures/`, loaded once per test run. Fast, explicit, and free of runtime cost, because nothing builds them at test time.

```yaml
# test/fixtures/users.yml
alice:
  name: Alice
  plan: pro
```

```ruby
def test_a_pro_user_sees_the_dashboard
  assert users(:alice).pro?
end
```

A large fixture file grows hard to read, and a fixture referenced by name couples tests to a shared record another test can also mutate. Keep fixtures small and named for what they represent, not for the test that first needed them.

## Factories

`factory_bot` (or `factory_bot_rails` in Rails) builds an object at test time, with just the attributes a test cares about:

```ruby
FactoryBot.define do
  factory :user do
    name { "Alice" }
    plan { "pro" }
  end
end

it "shows the dashboard to a pro user" do
  user = create(:user, plan: "pro")
  expect(user).to be_pro
end
```

Factories add indirection (a definition file, a sequence, a trait) and the runtime cost of building each record, in exchange for expressing exactly the attributes a test needs, inline, without a shared fixture file.

## A project with both

Detect the project's test data with `detect-tools`. A project can have `fixtures` and `factories` at once, most often mid-migration or where legacy tests kept fixtures while new tests moved to factories. Write a new test in whichever style the tests near it use; do not convert a fixture-based test to a factory or vice versa unless that is the task.

## Choosing for a new project

- A plain Ruby project or a Rails app with no existing preference: fixtures. They are explicit and add no gem.
- A project that already uses `factory_bot`: keep using it. Rewriting existing test data adds risk and checks nothing new.
- Never introduce a second test-data library into a project that already has one.

## Sources

- [Rails testing guide: fixtures](https://guides.rubyonrails.org/testing.html#the-low-down-on-fixtures)
- [factory_bot GETTING_STARTED](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md)
