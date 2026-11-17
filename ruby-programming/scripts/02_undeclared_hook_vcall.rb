# frozen_string_literal: true

puts "claim: calling an UNDECLARED hook with no receiver and no arguments raises NameError, not NoMethodError, so `rescue NoMethodError` in the caller misses it."
puts "ruby #{RUBY_VERSION}"

class Undeclared
  def run = call                 # vcall: parsed as "local variable or method"
  def run_explicit = call()      # fcall: parsed as a method call
  def run_self = self.call       # explicit receiver
end

%i[run run_explicit run_self].each do |m|
  Undeclared.new.public_send(m)
rescue NameError => e
  puts format("%-13s -> %-14s %s", m, e.class, e.message.lines.first.strip)
end

puts "NoMethodError < NameError => #{(NoMethodError < NameError).inspect}"

puts "-- a caller that rescues NoMethodError misses the vcall --"
begin
  begin
    Undeclared.new.run
  rescue NoMethodError => e
    puts "caught: #{e.class}"
  end
rescue NameError => e
  puts "ESCAPED `rescue NoMethodError`: #{e.class}"
end

puts "-- declaring the hook in the base class fixes both the class and the message --"
class Declared
  def call = raise(NoMethodError, "#{self.class}#call is not defined")
  def run = call
end
begin
  Declared.new.run
rescue NoMethodError => e
  puts "caught: #{e.class}: #{e.message}"
end
