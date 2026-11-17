# frozen_string_literal: true

puts "ruby #{RUBY_VERSION}"
puts "-- 1. ljust/length count CHARACTERS, not display columns --"
s = "café"
puts "   #{s.inspect} length=#{s.length} bytesize=#{s.bytesize} ljust(6).inspect=#{s.ljust(6).inspect}"
combining = "café"
puts "   #{combining.inspect} length=#{combining.length} (same glyph, different length)"
wide = "日本"
puts "   #{wide.inspect} length=#{wide.length} but it prints 4 columns wide -> a ljust table misaligns"

puts "-- 2. a String read from the environment or a file can have a non-UTF-8 encoding --"
b = "abc".dup.force_encoding("ASCII-8BIT")
puts "   #{b.encoding} + UTF-8 literal: #{begin
  (b + "é").encoding.to_s
rescue Encoding::CompatibilityError => e
  "#{e.class}"
end}"
bad = "\xff".dup.force_encoding("UTF-8")
puts "   invalid bytes: valid_encoding?=#{bad.valid_encoding?}; =~ raises: #{begin
  bad =~ /x/
rescue ArgumentError => e
  e.class.to_s
end}"
puts "   scrub fixes it: #{bad.scrub("?").inspect}"

puts "-- 3. sort is NOT stable in Ruby; sort_by with an index is --"
pairs = [["b", 1], ["a", 2], ["b", 3], ["a", 4]]
puts "   sort_by(&:first)                    = #{pairs.sort_by(&:first).inspect}"
puts "   sort_by.with_index { [k, i] } stable = #{pairs.each_with_index.sort_by { |(k, _), i| [k, i] }.map(&:first).inspect}"
puts "   (the docs say: 'The sort is not guaranteed to be stable.')"

puts "-- 4. Hash.new(default) shares ONE object across every miss --"
h = Hash.new([])
h[:a] << 1
h[:b] << 2
puts "   Hash.new([]): h[:a]=#{h[:a].inspect} h.keys=#{h.keys.inspect} (nothing was stored)"
g = Hash.new { |hash, k| hash[k] = [] }
g[:a] << 1
puts "   Hash.new { |h,k| h[k] = [] }: #{g.inspect}"

puts "-- 5. to_i and to_f never fail; Integer()/Float() do --"
%w[12abc abc 0x10 08].each do |v|
  i = begin
    Integer(v)
  rescue ArgumentError
    "ArgumentError"
  end
  puts format("   %-6s to_i=%-4s Integer()=%s", v.inspect, v.to_i, i)
end
puts "   Integer('08') is an ArgumentError because 0-prefixed means octal; Integer('08', 10) = #{Integer("08", 10)}"
puts "   Integer(nil) -> #{begin
  Integer(nil)
rescue TypeError => e
  e.class
end}; nil.to_i = #{nil.to_i}"

puts "-- 6. split with a limit, and the trailing-empty surprise --"
puts "   'a,b,,'.split(',')      = #{"a,b,,".split(",").inspect}   (trailing empties DROPPED)"
puts "   'a,b,,'.split(',', -1)  = #{"a,b,,".split(",", -1).inspect}"
puts "   ' a b '.split           = #{" a b ".split.inspect}   (no argument splits on runs of whitespace)"

puts "-- 7. Array#- and #| use hash/eql?, not == --"
class Weak
  def initialize(v) = @v = v
  def ==(o) = o.is_a?(Weak)
end
puts "   [Weak.new(1)] - [Weak.new(1)] = #{([Weak.new(1)] - [Weak.new(1)]).size} element(s) left"
puts "   (so a hand-rolled distance built on Array#- silently depends on hash/eql?)"

puts "-- 8. frozen literal deduplication: two literals are the SAME object --"
a = "x"
b = "x"
puts "   a.equal?(b) = #{a.equal?(b)} under frozen_string_literal"
