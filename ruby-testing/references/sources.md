# Sources

Where the testing practices in this skill come from. Open this when a person asks for the source of a practice, or wants to read further than a reference goes.

## How the research was verified

- The Minitest, testable design, and isolation guidance comes from verified research: 5 search angles, 24 sources fetched, 102 claims extracted, and 25 claims checked by 3-vote adversarial panels, which confirmed 24 and refuted 1.
- The Minitest 6, RSpec 3.13, SimpleCov 1.3, Mutineer 1.0, and Skunk facts were checked again against the installed gems and by runs on Ruby 4.0.3. The Minitest 5 advice that no longer held was corrected.
- Each reference lists its own sources at the end. This page collects them.

## Minitest

- [Minitest documentation](http://docs.seattlerb.org/minitest/)
- [Minitest style guide](https://github.com/rubocop/minitest-style-guide)
- [minitest-mock](https://rubygems.org/gems/minitest-mock)
- [minitest-around](https://github.com/splattael/minitest-around)
- [minitest-parallel_fork](https://github.com/jeremyevans/minitest-parallel_fork)
- [Minitest parallelization and you](https://www.zenspider.com/ruby/2012/12/minitest-parallelization-and-you.html)
- [Rails parallel testing with forked processes](https://github.com/rails/rails/pull/31900)
- [37signals: how do you test your software?](https://signalvnoise.com/posts/701-ask-37signals-how-do-you-test-your-software)

## RSpec

- [RSpec style guide](https://rspec.rubystyle.guide/)
- [RuboCop RSpec](https://docs.rubocop.org/rubocop-rspec/latest/index.html)
- [RSpec 3.13 feature documentation](https://rspec.info/features/3-13/rspec-core/)
- [rspec-rails](https://github.com/rspec/rspec-rails)

## Testable design and dependency injection

- [The testable Ruby script pattern](https://codeincomplete.com/articles/testable-ruby-script-pattern/)
- [How to test a Ruby CLI: the setup](https://lucaguidi.com/2017/01/20/how-to-test-ruby-cli-the-setup/)
- [Testing Ruby methods that use puts and gets](https://www.codewithjason.com/test-ruby-methods-involve-puts-gets/)
- [Testing a command line tool with plain Ruby](https://www.jorgemanrubia.com/2017/11/26/testing-a-command-line-tool-with-plain-ruby/)
- [Dependency injection in Ruby](https://gorails.com/episodes/dependency-injection-ruby)
- [Dependency injection and testability in Ruby](https://www.bytegod.com/posts/dependency-injection-and-testability-in-ruby/)
- [Practical metaprogramming in Minitest::Mock](https://wasabigeek.com/blog/practical-metaprogramming-in-ruby-minitest-mock/)

## Isolation and scale

- [Prefer Dir.mktmpdir for temporary folders](https://makandracards.com/makandra/516356-prefer-using-dir-mktmpdir-when-dealing-with-temporary-directories-in-ruby)
- [Exploring Minitest concurrency](https://chriskottom.com/articles/exploring-minitest-concurrency/)
- [The perils of parallel testing in Ruby on Rails](https://blog.appsignal.com/2022/03/16/the-perils-of-parallel-testing-in-ruby-on-rails.html)
- [Flaky Minitest tests](https://mergify.com/learn/flaky-tests/minitest/)

## Minitest compared with RSpec, and the 37signals style

- [Unofficial 37signals coding style guide](https://github.com/marckohlbrugge/unofficial-37signals-coding-style-guide)
- [37signals skills](https://github.com/marckohlbrugge/37signals-skills)
- [Minitest and RSpec in Rails](https://www.honeybadger.io/blog/minitest-rspec-rails/)
- [Minitest compared with RSpec](https://betterstack.com/community/guides/scaling-ruby/minitest-vs-rspec/)
- [Minitest or RSpec for Rails applications](https://testdrivingrails.com/blog/minitest-vs-rspec-for-testing-rails-applications)

## Verification tools

SimpleCov, Mutineer, Skunk, and RubyCritic are the ruby-quality-checking skill's own tools; its `sources.md` lists where their facts come from.

## Refuted

- "A direct class or module reference prevents substituting another implementation." The panel refuted it 1 to 2: Ruby permits substitution through open classes, `prepend`, and constant stubbing. Injection is the cleaner default, not the only option. Source: [Dependency injection in Ruby](https://gorails.com/episodes/dependency-injection-ruby).
