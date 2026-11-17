# frozen_string_literal: true

puts "ruby #{RUBY_VERSION}"

puts "-- 1. method_missing without respond_to_missing? breaks respond_to?, method() and &:sym --"
class Ghost
  def method_missing(name, *args) = name.to_s.start_with?("get_") ? name.to_s.delete_prefix("get_") : super
end
g = Ghost.new
puts "   g.get_x            = #{g.get_x.inspect}"
puts "   g.respond_to?(:get_x) = #{g.respond_to?(:get_x)}"
begin; g.method(:get_x); rescue NameError => e; puts "   g.method(:get_x)   -> #{e.class}: #{e.message.lines.first.strip}"; end
class Polite < Ghost
  def respond_to_missing?(name, include_private = false) = name.to_s.start_with?("get_") || super
end
p2 = Polite.new
puts "   polite respond_to? = #{p2.respond_to?(:get_x)}; method() = #{p2.method(:get_x).inspect}"
puts "   super in method_missing still gives a real NoMethodError:"
begin; p2.nope; rescue NoMethodError => e; puts "     #{e.class}: #{e.message.lines.first.strip}"; end

puts "-- 2. define_method closes over the loop variable; def does not see it at all --"
class Closure
  %w[a b].each { |n| define_method("get_#{n}") { n } }
end
puts "   #{Closure.new.get_a.inspect} #{Closure.new.get_b.inspect}"
puts "   define_method makes the block's return value the method's; `return` inside it returns from the METHOD:"
class R
  define_method(:m) { return 1; 2 }
end
puts "   #{R.new.m.inspect}"

puts "-- 3. prepend vs alias chaining: prepend lets super work and survives re-definition --"
module Logged
  def work = "logged(#{super})"
end
class Worker
  prepend Logged
  def work = "work"
end
puts "   prepend: #{Worker.new.work}"
puts "   ancestors: #{Worker.ancestors.first(3).inspect}"
module Included
  def work = "included(#{super rescue 'no super'})"
end
class Worker2
  include Included
  def work = "work"      # the class's own method WINS over an included module
end
puts "   include: #{Worker2.new.work}   (the module never runs)"

puts "-- 4. alias_method chain double-wraps when the file is loaded twice --"
class Chained
  def work = "work"
  2.times do
    alias_method :work_without_log, :work
    def work = "logged(#{work_without_log})"
  end
end
begin
  puts "   #{Chained.new.work}"
rescue SystemStackError => e
  puts "   #{e.class}: infinite recursion from a double alias chain"
end

puts "-- 5. Module#refine is lexically scoped and invisible to send/respond_to? --"
module Up
  refine String do
    def shout = upcase
  end
end
puts "   without `using`: #{("x".shout rescue "NoMethodError")}"
