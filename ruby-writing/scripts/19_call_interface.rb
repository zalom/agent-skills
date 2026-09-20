# frozen_string_literal: true

puts "claim: a class that does one job exposes self.call, which runs new(...).call"
puts "claim: a base class whose call raises does no work before it raises"

class Job
  def self.call(...)
    new(...).call
  end

  def initialize(name, log: [])
    @name = name
    @log = log
  end

  def call
    raise NoMethodError, "#{self.class} must define call"
  end
end

class Greet < Job
  def call
    @log << "greeted #{@name}"
    "hello #{@name}"
  end
end

class EagerJob < Job
  def self.call(...)
    job = new(...)
    job.prepare
    job.call
  end

  def prepare
    @log << "prepared"
  end
end

def check(label, ok)
  puts "  #{ok ? 'ok  ' : 'FAIL'} #{label}"
  exit 1 unless ok
end

check "Greet.call builds and runs", Greet.call("Ana") == "hello Ana"
check "keywords pass through ...", Greet.call("Ana", log: (seen = [])) && seen == ["greeted Ana"]
check "a lambda answers the same message", ->(name) { "hello #{name}" }.call("Ana") == Greet.call("Ana")

error = begin
  Job.call("Ana")
rescue NoMethodError => e
  e
end
check "the base class raises NoMethodError with its name", error.message == "Job must define call"

wasted = []
begin
  EagerJob.call("Ana", log: wasted)
rescue NoMethodError
  nil
end
check "wrong form: work ran before a call that had to fail", wasted == ["prepared"]
