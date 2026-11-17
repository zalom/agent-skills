# frozen_string_literal: true

puts "ruby #{RUBY_VERSION}"
puts "-- 1. `class A::B` does NOT open A's lexical scope: constants in A are invisible --"
module Outer
  VALUE = :outer_value
  class Inner
    def lexical = VALUE
  end
end
class Outer::Compact
  def compact = (VALUE rescue "NameError: VALUE not found")
end
puts "   nested form:  #{Outer::Inner.new.lexical.inspect}"
puts "   compact form: #{Outer::Compact.new.compact.inspect}"

puts "-- 2. constant lookup is lexical scope first, THEN the ancestors of the innermost scope --"
class Parent; NAME = :parent; end
class ChildA < Parent
  def name = NAME
end
puts "   inherited constant: #{ChildA.new.name.inspect}"
module Mixin; NAME2 = :mixin; end
class UsesMixin
  include Mixin
  def name = NAME2
end
puts "   constant from an included module: #{UsesMixin.new.name.inspect}"
puts "   but NOT from the singleton/`Object` of the CALLER:"
module Deep; class D; def n = (MISSING_CONST rescue "NameError"); end; end
puts "   #{Deep::D.new.n.inspect}"

puts "-- 3. a frozen constant is not a deep freeze --"
LIST = ["a"].freeze
puts "   LIST.frozen? = #{LIST.frozen?}, LIST.first.frozen? = #{LIST.first.frozen?}"
LIST.first << "b" rescue puts("   (string literal frozen by the magic comment)")
puts "   LIST = #{LIST.inspect}"
H = { a: [1] }.freeze
H[:a] << 2
puts "   a frozen Hash with a mutable value: #{H.inspect}"

puts "-- 4. reassigning a constant only WARNS --"
X = 1
X = 2
puts "   X = #{X}"

puts "-- 5. require_relative resolves against the FILE, require against $LOAD_PATH --"
puts "   __dir__ = #{__dir__}"
puts "   require_relative is idempotent by REALPATH; a symlinked copy loads twice."
puts "-- 6. `require` returns false the second time, which is not an error --"
puts "   require 'json' -> #{require("json").inspect}; again -> #{require("json").inspect}"
