# frozen_string_literal: true

puts "ruby #{RUBY_VERSION}"
puts "-- 1. raise with a String makes a RuntimeError --"
begin; raise "plain"; rescue => e; puts "   #{e.class}: #{e.message}"; end

puts "-- 2. raise with a class calls .new with no message --"
class Custom < StandardError
  def initialize(msg = "default message") = super
end
begin; raise Custom; rescue => e; puts "   #{e.class}: #{e.message}"; end

puts "-- 3. a custom initialize that forgets to call super loses the message --"
class Broken < StandardError
  def initialize(detail) = @detail = detail
end
begin; raise Broken.new("payload"); rescue => e; puts "   #{e.class}: message=#{e.message.inspect} (the class name, not the payload)"; end
class Fixed < StandardError
  def initialize(detail)
    @detail = detail
    super("failed on #{detail}")
  end
end
begin; raise Fixed.new("payload"); rescue => e; puts "   #{e.class}: #{e.message}"; end

puts "-- 4. `cause` is set automatically inside a rescue --"
begin
  begin
    raise "inner"
  rescue
    raise Custom, "outer"
  end
rescue => e
  puts "   #{e.class}: #{e.message}; cause = #{e.cause.class}: #{e.cause&.message}"
end

puts "-- 5. `raise` with no arguments re-raises $! inside a rescue, RuntimeError outside --"
begin
  begin; raise "original"; rescue; raise; end
rescue => e
  puts "   inside rescue: #{e.class}: #{e.message}"
end
begin; raise; rescue => e; puts "   outside rescue: #{e.class}: #{e.message.inspect}"; end

puts "-- 6. rescue Exception catches signals and Interrupt; rescue StandardError does not --"
puts "   Interrupt < StandardError      => #{(Interrupt < StandardError).inspect}"
puts "   SignalException < StandardError=> #{(SignalException < StandardError).inspect}"
puts "   SystemExit < StandardError     => #{(SystemExit < StandardError).inspect}"
puts "   NoMemoryError < StandardError  => #{(NoMemoryError < StandardError).inspect}"
puts "   Timeout::Error < StandardError => #{(require("timeout"); Timeout::Error < StandardError).inspect}"

puts "-- 7. `rescue` in a one-line modifier only catches StandardError --"
begin
  v = (raise NotImplementedError rescue :caught) rescue :escaped
  puts "   #{v.inspect}"
rescue NotImplementedError => e
  puts "   BOTH modifier rescues missed it: #{e.class}"
end

puts "-- 8. a rescue clause with a non-class raises TypeError --"
begin
  begin; raise "x"; rescue "not a class"; end
rescue TypeError => e
  puts "   #{e.class}: #{e.message}"
end
