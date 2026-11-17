# frozen_string_literal: true

puts "ruby #{RUBY_VERSION}"
puts "-- 1. `@x ||= expr` re-runs the work forever when the answer is nil or false --"
class Memo
  def initialize = @calls = 0
  attr_reader :calls
  def falsey = @falsey ||= (@calls += 1; nil)
  def defined_guard
    return @guard if defined?(@guard)

    @calls += 1
    @guard = nil
  end
end
m = Memo.new
3.times { m.falsey }
puts "   ||= with a nil result: #{m.calls} calls for 3 reads"
m2 = Memo.new
3.times { m2.defined_guard }
puts "   defined?(@guard):      #{m2.calls} call for 3 reads"

puts "-- 2. the `@x ||= ...` idiom warns under -W when the ivar is new --"
puts "   (run with `ruby -w`: 'instance variable @x not initialized' was removed in Ruby 3.0; no warning now)"

puts "-- 3. `defined?(@x)` is true even when @x is nil, and false after remove_instance_variable --"
class D; def set = @v = nil; def has = defined?(@v) ? "defined" : "undefined"; end
d = D.new
puts "   before set: #{d.has}; after set: #{d.set; d.has}"

puts "-- 4. memoization is NOT thread safe: two threads can both run the work --"
class Racy
  def initialize = @runs = 0
  attr_reader :runs
  def value
    @value ||= begin
      @runs += 1
      sleep 0.01
      :done
    end
  end
end
r = Racy.new
4.times.map { Thread.new { r.value } }.each(&:join)
puts "   runs = #{r.runs} for 4 concurrent readers (1 would mean it was safe)"

puts "-- 5. a Hash is not thread safe either --"
h = {}
threads = 8.times.map { |i| Thread.new { 500.times { |j| h["#{i}-#{j}"] = j } } }
threads.each(&:join)
puts "   entries = #{h.size} of 4000 expected (MRI's GVL usually saves this, other rubies do not)"

puts "-- 6. a frozen object is still not thread safe if it holds mutable state --"
CONFIG = { list: [] }.freeze
2.times.map { Thread.new { 100.times { CONFIG[:list] << 1 } } }.each(&:join)
puts "   CONFIG[:list].size = #{CONFIG[:list].size} (freeze is shallow)"

puts "-- 7. Ractor gives real isolation but rejects unshareable objects --"
begin
  arr = []
  Ractor.new(arr) { |a| a << 1 }.value
rescue => e
  puts "   #{e.class}: #{e.message.lines.first.strip}"
end
