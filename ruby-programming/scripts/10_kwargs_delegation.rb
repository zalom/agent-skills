# frozen_string_literal: true

puts "ruby #{RUBY_VERSION}"

puts "-- 1. Ruby 3 separates positional and keyword arguments --"
def kw(a, b: nil) = [a, b]
puts "   kw({b: 1})       = #{kw({ b: 1 }).inspect}   (a Hash stays positional)"
puts "   kw(1, **{b: 2})  = #{kw(1, **{ b: 2 }).inspect}"
begin; kw(**{ b: 1 }); rescue ArgumentError => e; puts "   kw(**{b: 1}) -> #{e.class}: #{e.message}"; end

puts "-- 2. `*args, &block` delegation LOSES keywords in Ruby 3 --"
def target(a, b: :default) = [a, b]
def bad_delegate(*args, &blk) = target(*args, &blk)
def ruby2_style(*args, **kw, &blk) = target(*args, **kw, &blk)
def modern(...) = target(...)
begin
  puts "   bad_delegate(1, b: 2) = #{bad_delegate(1, b: 2).inspect}"
rescue ArgumentError => e
  puts "   bad_delegate(1, b: 2) -> #{e.class}: #{e.message}"
end
puts "   ruby2_style(1, b: 2)  = #{ruby2_style(1, b: 2).inspect}"
puts "   modern(1, b: 2)       = #{modern(1, b: 2).inspect}   (`...` forwards everything)"

puts "-- 3. anonymous forwarding (3.2 for *, **, 3.1 for &) --"
def anon(*, **, &) = target(*, **, &)
puts "   anon(1, b: 3) = #{anon(1, b: 3).inspect}"

puts "-- 4. **nil declares 'this method takes no keywords' --"
def no_kw(a, **nil) = a
puts "   no_kw(1) = #{no_kw(1).inspect}"
begin; no_kw(1, b: 2); rescue ArgumentError => e; puts "   no_kw(1, b: 2) -> #{e.class}: #{e.message}"; end
def takes_hash(a) = a
puts "   without **nil, no_kw-less method swallows it as a Hash: #{takes_hash(b: 2).inspect}"

puts "-- 5. a block argument's arity is lenient; a lambda's is strict --"
pr = proc { |a, b| [a, b] }
la = lambda { |a, b| [a, b] }
puts "   proc.call(1)      = #{pr.call(1).inspect}"
begin; la.call(1); rescue ArgumentError => e; puts "   lambda.call(1) -> #{e.class}: #{e.message}"; end
puts "   proc auto-splats an array: #{proc { |a, b| [a, b] }.call([1, 2]).inspect}"
puts "   lambda does not:           #{(lambda { |a, b| [a, b] }.call([1, 2]) rescue 'ArgumentError')}"

puts "-- 6. `return` inside a proc returns from the enclosing method; inside a lambda it does not --"
def uses_lambda = (lambda { return :from_lambda }.call; :from_method)
puts "   #{uses_lambda.inspect}"

puts "-- 7. default values are evaluated left to right, at call time --"
def defaults(a = [], b = a << 1) = [a, b]
puts "   #{defaults.inspect} then #{defaults.inspect}   (a fresh [] each call)"
COUNTER = []
def shared(a = COUNTER) = (a << 1; a.size)
puts "   a shared mutable default grows: #{shared} #{shared}"

puts "-- 8. a keyword with no default is REQUIRED; `key: nil` is optional --"
def required(a:) = a
begin; required; rescue ArgumentError => e; puts "   #{e.class}: #{e.message}"; end
