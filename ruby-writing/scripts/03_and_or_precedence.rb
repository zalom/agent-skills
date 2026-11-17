# frozen_string_literal: true

puts "claim: `and`/`or` are control flow, not boolean operators, and `x and CONST` returns the WRONG value when x is falsey."
puts "ruby #{RUBY_VERSION}"
USAGE = 2

def truthy_usage(value) = (value and USAGE)
puts "-- 1. `x and USAGE` depends on x being truthy --"
[nil, false, "printed", 0, ""].each do |v|
  puts format("  value=%-9s -> %s", v.inspect, truthy_usage(v).inspect)
end

puts "-- 2. real methods that return nil or false --"
out = StringIO.new rescue nil
require "stringio"
io = StringIO.new
puts "  io.puts('x')        => #{io.puts("x").inspect}   (IO#puts returns nil)"
h = {a: 1}
puts "  h.delete(:missing)  => #{h.delete(:missing).inspect}"
a = [1]
puts "  a.reject!{false}    => #{a.reject! { false }.inspect}  (returns nil when nothing changed)"
puts "  'ab'.sub!(/z/,'')   => #{(+"ab").sub!(/z/, "").inspect}"

puts "-- 3. precedence: `and` binds looser than `=` --"
x = (1 == 2) && "b"
puts "  x = (1==2) && 'b'  -> x = #{x.inspect}"
y = (1 == 2) and "b"
puts "  y = (1==2) and 'b' -> y = #{y.inspect}   (the `and` runs AFTER the assignment)"

puts "-- 4. the fix: a statement, then the value --"
def explicit_usage(io, message)
  io.puts(message)
  USAGE
end
puts "  explicit_usage(io, nil)  => #{explicit_usage(io, nil).inspect}"

puts "-- 5. only nil and false are falsey --"
[0, "", [], {}, :"", Float::NAN].each { |v| puts format("  %-12s truthy? %s", v.inspect, (v ? true : false)) }
