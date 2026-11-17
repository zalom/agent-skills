# frozen_string_literal: true

puts "claim: ensure does not change the return value UNLESS it returns; and an explicit return inside ensure swallows the exception silently."
puts "ruby #{RUBY_VERSION}"

def plain
  :body
ensure
  :ensure_value
end
puts "1. ensure with a bare last expression        -> #{plain.inspect}"

def returning
  :body
ensure
  return :ensure_return
end
puts "2. ensure with `return`                       -> #{returning.inspect}"

def swallows
  raise "boom"
ensure
  return :swallowed
end
puts "3. `return` in ensure SWALLOWS the exception  -> #{swallows.inspect}"

def breaks_in_block
  [1].each { raise "boom" }
rescue => e
  "rescued #{e.message}"
end
puts "4. ordinary rescue                            -> #{breaks_in_block.inspect}"

puts "-- 5. rescue-else runs only when nothing raised, and its value is the result --"
def with_else
  :body
rescue
  :rescued
else
  :else_value
end
puts "   #{with_else.inspect}"

puts "-- 6. `retry` outside rescue is a SyntaxError --"
begin
  eval("def x; retry; end")
rescue SyntaxError => e
  puts "   #{e.class}: #{e.message.lines.grep(/retry/).first&.strip || e.message.lines.first.strip}"
end

puts "-- 7. a method-level rescue does NOT cover the evaluation of default arguments --"
def defaults(a = (raise "in default"))
  a
rescue => e
  "rescued: #{e.message}"
end
begin
  puts "   #{defaults.inspect}"
rescue RuntimeError => e
  puts "   ESCAPED the method-level rescue: #{e.class}: #{e.message}"
end

puts "-- 8. ensure runs on `next`/`break` too --"
log = []
[1, 2].each do |i|
  begin
    next if i == 1
    log << :body
  ensure
    log << [:ensure, i]
  end
end
puts "   #{log.inspect}"
