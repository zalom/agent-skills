# Collaboration tests

How to write a test that checks a class sends the right message to the right collaborator, for a given input, and that the collaborator's own tests cover what it does with it. Open this when a class exists to delegate work: charge a gateway, deliver a mailer, enqueue a job, or call another service object.

## Contents

- Why a collaboration test
- Minitest
- RSpec
- Rails mailers and jobs
- What not to assert
- Sources

## Why a collaboration test

A unit test checks a public result or a direct side effect. A collaboration test checks that the right message reached the right object with the right arguments, then trusts that object's own tests to cover what it does next. A mock or a spy on an internal collaborator is a collaboration test, not a problem to avoid, as long as it checks a message the code exists to send. `minitest-idioms.md` and `rspec-practices.md` point here for that.

## Minitest

```ruby
def test_charges_the_gateway_the_order_total
  gateway = Minitest::Mock.new
  gateway.expect(:charge, true, [4_999])

  Checkout.new(gateway: gateway).complete(Order.new(total: 4_999))

  assert_mock gateway
end
```

`Minitest::Mock#expect` checks the method name, the return value, and the arguments together. `assert_mock` fails when an expected call never happened.

## RSpec

```ruby
it "charges the gateway the order total" do
  gateway = instance_double(Gateway)
  allow(gateway).to receive(:charge)

  Checkout.new(gateway: gateway).complete(Order.new(total: 49_99))

  expect(gateway).to have_received(:charge).with(49_99)
end
```

`instance_double` checks the stubbed method exists on the real class, as `rspec-practices.md` shows. `have_received` reads as a spy: stub first, act, then check the call happened.

## Rails mailers and jobs

Rails ships assertions built for this. Reach for them before a hand-rolled mock:

- Minitest: `assert_enqueued_email_with(OrderMailer, :confirmation, args: [order])`, `assert_enqueued_with(job: ReceiptJob, args: [order.id])`, `assert_emails 1 { ... }`.
- RSpec (`rspec-rails`): `expect { checkout.complete }.to have_enqueued_mail(OrderMailer, :confirmation)`, `have_enqueued_job(ReceiptJob)`.

Fall back to `Minitest::Mock` or `instance_double` with `have_received` only for a plain collaborator that has no Rails helper.

## What not to assert

- Never assert a private method was called. Test the public message.
- Never assert every call a method makes; assert the ones the test's name is about.
- An outgoing query (a collaborator asked for a value, not told to act) is stubbed to return a value, not asserted as a call: the assertion belongs on what the code does with the value.

## Sources

- [Minitest::Mock documentation](http://docs.seattlerb.org/minitest/Minitest/Mock.html)
- [RSpec verifying doubles](https://rspec.info/features/3-13/rspec-mocks/verifying-doubles/)
- [Rails ActionMailer::TestHelper](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html)
- [Rails ActiveJob::TestHelper](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html)
- [rspec-rails matchers](https://github.com/rspec/rspec-rails)
