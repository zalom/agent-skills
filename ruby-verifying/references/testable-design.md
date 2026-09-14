# Testable design

How to shape Ruby code so a test passes collaborators in instead of patching globals. Open this when code is hard to test because it reads `ENV`, a top-level constant, the filesystem, the clock, or `$stdout` directly, or when a script does its work as soon as a test loads it.

## Contents

- Inject collaborators
- The testable script
- Config objects
- The anti-pattern
- Injection is the default, not the only way
- Sources

## Inject collaborators

This method reads a global, calls the network, and writes a fixed path, so a test cannot control any of them:

```ruby
class Report
  def generate
    data = HTTP.get(ENV["API_URL"])
    File.write("/var/out/report.txt", data)
  end
end
```

Pass each dependency in as a constructor argument, a method argument, or a config object, and keep the real value as the default:

```ruby
class Report
  def initialize(client: HTTP, url: ENV["API_URL"], out: File)
    @client = client
    @url = url
    @out = out
  end

  def generate(path)
    @out.write(path, @client.get(@url))
  end
end
```

A test passes a fake client, a fixed URL, and a path in a temporary folder, and touches no global.

## The testable script

A script stays runnable as `ruby tool.rb` and testable when its logic lives in a class that takes its collaborators, behind a guarded entry point:

```ruby
class Tool
  def initialize(out: $stdout, err: $stderr, env: ENV, home: Dir.home, clock: Time)
    @out = out
    @err = err
    @env = env
    @home = home
    @clock = clock
  end

  def run(argv)
    @out.puts "running in #{@home}"
    0
  end
end

exit Tool.new.run(ARGV) if $PROGRAM_NAME == __FILE__
```

- `$PROGRAM_NAME` equals the file path only when the file runs directly. A test that requires or loads the file gets the class and runs nothing.
- Inject IO (`out:`, `err:`, `input:`) and pass `StringIO` in tests, instead of reassigning `$stdout` or `$stdin`.
- Inject the clock (`clock: Time`, then `@clock.now`) so time is deterministic.
- Inject paths, the home folder, and settings, and point them at `Dir.mktmpdir` in tests.
- Inject subprocess and git runners as lambdas. `bin/verify-change` takes `git:` and `run:` this way, and its tests pass stubs.

The same test in Minitest:

```ruby
def test_runs_in_the_home_folder
  Dir.mktmpdir do |dir|
    out = StringIO.new
    Tool.new(out: out, home: dir, env: {}).run([])
    assert_includes out.string, dir
  end
end
```

And in RSpec:

```ruby
it "runs in the home folder" do
  Dir.mktmpdir do |dir|
    out = StringIO.new
    described_class.new(out: out, home: dir, env: {}).run([])
    expect(out.string).to include(dir)
  end
end
```

## Config objects

When many settings travel together, pass one config object instead of a long argument list:

```ruby
Config = Data.define(:home, :agents, :verbose)
Tool.new(config: Config.new(home: tmp, agents: {}, verbose: false))
```

The default builds the real config, and a test builds one backed by a temporary folder. Settings that would otherwise be top-level constants become fields of the injected config.

## The anti-pattern

```ruby
source = File.read("script.rb").sub("HOME = ENV.fetch(\"HOME\")", "HOME = #{tmp.inspect}")
eval(source, TOPLEVEL_BINDING)
```

Rewriting a script's source and evaluating it into the top-level binding mutates global state, couples test files to each other, and breaks under random or parallel order. Wrap the script's logic in a class that accepts `home:` or `config:`, with the real values as defaults, and pass a temporary folder in the test.

## Injection is the default, not the only way

A method that references another class directly is still testable in Ruby: you can reopen the class, `prepend` a module, or stub a constant. The research behind this skill refuted the claim that a direct reference prevents substitution. Choose injection for clarity, decoupling, and readable tests, not because the alternatives are impossible.

## Sources

- [The testable Ruby script pattern](https://codeincomplete.com/articles/testable-ruby-script-pattern/)
- [How to test a Ruby CLI: the setup](https://lucaguidi.com/2017/01/20/how-to-test-ruby-cli-the-setup/)
- [Testing Ruby methods that use puts and gets](https://www.codewithjason.com/test-ruby-methods-involve-puts-gets/)
- [Testing a command line tool with plain Ruby](https://www.jorgemanrubia.com/2017/11/26/testing-a-command-line-tool-with-plain-ruby/)
- [Dependency injection in Ruby](https://gorails.com/episodes/dependency-injection-ruby)
- [Dependency injection and testability in Ruby](https://www.bytegod.com/posts/dependency-injection-and-testability-in-ruby/)
