# frozen_string_literal: true

puts "claim: NotImplementedError is NOT a StandardError; abstract hooks should raise NoMethodError."
puts "ruby #{RUBY_VERSION}"

puts "-- 1. ancestry --"
puts "NotImplementedError.ancestors[0,5] = #{NotImplementedError.ancestors.first(5).inspect}"
puts "NoMethodError.ancestors[0,5]       = #{NoMethodError.ancestors.first(5).inspect}"
puts "NotImplementedError < StandardError => #{(NotImplementedError < StandardError).inspect}"
puts "NoMethodError < StandardError       => #{(NoMethodError < StandardError).inspect}"

puts "-- 2. a bare rescue MISSES NotImplementedError --"
def bare_rescue
  yield
rescue => e            # bare rescue == rescue StandardError
  "caught #{e.class}"
end
begin
  puts bare_rescue { raise NotImplementedError, "hook" }
rescue NotImplementedError => e
  puts "ESCAPED the bare rescue: #{e.class}: #{e.message}"
end
puts bare_rescue { raise NoMethodError, "hook" }

puts "-- 3. what Ruby itself raises for a missing method --"
begin
  Object.new.no_such_method
rescue => e
  puts "#{e.class}: #{e.message.lines.first.strip}"
end

puts "-- 4. NotImplementedError is what Ruby raises for an unsupported PLATFORM feature --"
begin
  Process.fork { } if false
  File.lchmod(0o644, "/nonexistent-path-xyz")
rescue NotImplementedError => e
  puts "NotImplementedError from a platform feature: #{e.message}"
rescue => e
  puts "(this platform: #{e.class}: #{e.message})"
end

puts "-- 5. the template-method shape --"
class BaseDeclared
  def call = raise(NoMethodError, "#{self.class}#perform is not defined")
end
class BaseUndeclared
  def run = call         # calls an undeclared hook
end
begin
  BaseDeclared.new.call
rescue => e
  puts "declared hook, rescued by a plain rescue: #{e.class}"
end
begin
  BaseUndeclared.new.run
rescue NameError => e
  puts "undeclared hook: #{e.class}: #{e.message.lines.first.strip}"
end
