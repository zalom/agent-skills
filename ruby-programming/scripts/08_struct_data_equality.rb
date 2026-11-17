# frozen_string_literal: true

puts "ruby #{RUBY_VERSION}"

puts "-- 1. Struct.new positional vs keyword_init --"
S = Struct.new(:x, :y)
puts "   S.new(1)        = #{S.new(1).inspect}   (missing members become nil, no error)"
begin; S.new(x: 1); rescue ArgumentError => e; puts "   S.new(x: 1) -> #{e.class}: #{e.message}"; end
K = Struct.new(:x, :y, keyword_init: true)
puts "   K.new(x: 1)     = #{K.new(x: 1).inspect}"
puts "   S.new(1,2).frozen? = #{S.new(1, 2).frozen?}  (a Struct is MUTABLE)"

puts "-- 2. Data is immutable, keyword-or-positional, and rejects missing members --"
D = Data.define(:x, :y)
puts "   D.new(x: 1, y: 2) = #{D.new(x: 1, y: 2).inspect}"
puts "   D.new(1, 2)       = #{D.new(1, 2).inspect}"
begin; D.new(x: 1); rescue ArgumentError => e; puts "   D.new(x: 1) -> #{e.class}: #{e.message}"; end
d = D.new(1, 2)
puts "   d.frozen? = #{d.frozen?}"
begin; d.instance_variable_set(:@x, 9); rescue FrozenError => e; puts "   mutating -> #{e.class}"; end
puts "   d.with(x: 9) = #{d.with(x: 9).inspect}"
begin; D.define; rescue => e; puts "   #{e.class}"; end
puts "   Data has no []= and no to_a: respond_to?(:to_a) = #{d.respond_to?(:to_a)}, respond_to?(:deconstruct) = #{d.respond_to?(:deconstruct)}"

puts "-- 3. a Struct used as a Hash key mutates its way out of the bucket --"
h = {}
s = S.new(1, 2)
h[s] = :v
s.x = 99
puts "   after mutating the key: h[s] = #{h[s].inspect}, h.keys.first = #{h.keys.first.inspect}"
puts "   rehash fixes it: #{(h.rehash; h[s]).inspect}"

puts "-- 4. == without eql?/hash: the object works in an Array but not in a Hash or Set --"
class ValueBad
  attr_reader :v
  def initialize(v) = @v = v
  def ==(other) = other.is_a?(ValueBad) && v == other.v
end
a, b = ValueBad.new(1), ValueBad.new(1)
puts "   a == b            #{a == b}"
puts "   [a].include?(b)   #{[a].include?(b)}   (Array#include? uses ==)"
puts "   {a=>1}[b]         #{{ a => 1 }[b].inspect}   (Hash uses hash + eql?)"
require "set"
puts "   Set[a].include?(b) #{Set[a].include?(b)}"
puts "   a.eql?(b)         #{a.eql?(b)}   (eql? was NOT redefined)"

class ValueGood
  attr_reader :v
  def initialize(v) = @v = v
  def ==(other) = other.instance_of?(ValueGood) && v == other.v
  alias_method :eql?, :==
  def hash = [self.class, v].hash
end
g, h2 = ValueGood.new(1), ValueGood.new(1)
puts "   good: {g=>1}[h2] = #{{ g => 1 }[h2].inspect}, Set[g].include?(h2) = #{Set[g].include?(h2)}"

puts "-- 5. Comparable needs <=> to return nil for incomparables, not raise --"
class Version
  include Comparable
  attr_reader :n
  def initialize(n) = @n = n
  def <=>(other) = other.is_a?(Version) ? n <=> other.n : nil
end
puts "   Version.new(1) < Version.new(2) = #{Version.new(1) < Version.new(2)}"
begin; Version.new(1) < 2; rescue ArgumentError => e; puts "   Version.new(1) < 2 -> #{e.class}: #{e.message}"; end
puts "   Comparable gives ==, but NOT hash: Version.new(1) == Version.new(1) -> #{Version.new(1) == Version.new(1)}"
puts "   {Version.new(1)=>:x}[Version.new(1)] -> #{{ Version.new(1) => :x }[Version.new(1)].inspect}"

puts "-- 6. Data/Struct get ==, eql? and hash for free --"
puts "   {D.new(1,2)=>:x}[D.new(1,2)] = #{{ D.new(1, 2) => :x }[D.new(1, 2)].inspect}"
puts "   {S.new(1,2)=>:x}[S.new(1,2)] = #{{ S.new(1, 2) => :x }[S.new(1, 2)].inspect}"
