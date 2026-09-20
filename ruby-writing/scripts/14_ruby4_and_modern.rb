# frozen_string_literal: true

puts "ruby #{RUBY_VERSION} #{RUBY_RELEASE_DATE}"

puts "-- 1. `it` (3.4) is the implicit first block parameter; _1 still works --"
puts "   [1,2].map { it * 2 }  = #{[1, 2].map { it * 2 }.inspect}"
puts "   [1,2].map { _1 * 2 }  = #{[1, 2].map { _1 * 2 }.inspect}"
puts "   a local named `it` shadows it:"
it = :local
puts "   #{[1].map { it }.inspect}"

puts "-- 2. Hash#inspect changed in 3.4: symbol keys now print as `key: value` --"
puts "   #{{ a: 1, "b" => 2, :"c d" => 3 }.inspect}"

puts "-- 3. frozen string literals: the chilled-string warning --"
puts "   RUBY_VERSION #{RUBY_VERSION}; this file HAS the magic comment, so literals are frozen"
puts "   'x'.frozen? = #{"x".frozen?}"
code = 'a = "y"; a << "z"; a'
puts "   a file WITHOUT the comment, eval'd: #{eval(code).inspect} (no error in 4.0)"

puts "-- 4. what moved out of the default gems --"
%w[ostruct logger benchmark irb csv base64 mutex_m observer fiddle rexml].each do |lib|
  ok = begin
    require lib
    :loads
  rescue LoadError
    :LoadError
  end
  spec = Gem.loaded_specs[lib]
  puts format("   %-10s %-9s %s", lib, ok, spec ? "gem #{spec.version} (#{spec.default_gem? ? "default" : "BUNDLED"})" : "built in / not a gem")
end

puts "-- 5. removed or changed in Ruby 3.x/4.0 that old advice still recommends --"
checks = {
  "Object#taint"             => -> { Object.new.respond_to?(:taint) },
  "File.exists? (alias)"     => -> { File.respond_to?(:exists?) },
  "Dir.exists? (alias)"      => -> { Dir.respond_to?(:exists?) },
  "Fixnum"                   => -> { Object.const_defined?(:Fixnum) },
  "SortedSet"                => -> { (require "set"; Object.const_defined?(:SortedSet)) },
  "Set is autoloaded core"   => -> { Object.const_defined?(:Set) },
  "ENV.freeze allowed"       => -> { begin; ENV.freeze; true; rescue => e; e.class.to_s; end },
  "Kernel#open with |pipe"   => -> { "see docs: URI.open / IO.popen instead" },
  "Comparable#clamp"         => -> { 5.clamp(1, 3) },
  "Data.define"              => -> { Object.const_defined?(:Data) },
  "Hash#except"              => -> { {}.respond_to?(:except) },
  "Array#sum"                => -> { [1].respond_to?(:sum) },
  "String#-@ (dedup)"        => -> { (-"x").frozen? },
  "Module#set_temporary_name"=> -> { Module.new.respond_to?(:set_temporary_name) },
  "Range#step on non-num"    => -> { ("a".."e").respond_to?(:step) }
}
checks.each { |name, fn| puts format("   %-27s %s", name, (fn.call.inspect rescue "raised")) }

puts "-- 6. endless method gotcha: `def m = a b` needs parentheses when the body is a command call --"
begin
  eval("def broken = puts 'x', 'y'")
  puts "   parsed"
rescue SyntaxError => e
  puts "   SyntaxError: #{e.message.lines.grep(/\^|syntax/).first&.strip}"
end
puts "   `def m = value` with setter-like names is a SyntaxError:"
begin
  eval("class Z; def x=(v) = @x = v; end")
rescue SyntaxError => e
  puts "   SyntaxError for `def x=(v) = ...` (setters cannot be endless)"
end

puts "-- 7. pattern matching: `in` returns true/false, `=>` raises --"
h = { a: 1 }
puts "   h in {a: Integer} = #{(h in { a: Integer })}"
puts "   h in {b: Integer} = #{(h in { b: Integer })}"
begin
  h => { b: Integer }
rescue NoMatchingPatternKeyError, NoMatchingPatternError => e
  puts "   h => {b: Integer} raises #{e.class}"
end
puts "   a `case/in` with no match also raises, unlike `case/when`:\n"
begin
  case 1
  in String then :never
  end
rescue NoMatchingPatternError => e
  puts "   #{e.class}: case/in with no else"
end
puts "   case/when with no match returns #{(case 1 when String then :never end).inspect}"
