# frozen_string_literal: true

puts "claim: Reproduces bug 13804 \"Protected methods cannot be overridden\" (bugs.ruby-lang.org/issues/13804)"
puts "ruby #{RUBY_VERSION}"
class Person
  def initialize(ssn) = @ssn = ssn
  def same?(other) = ssn == other.ssn
  protected
  def ssn = @ssn
end
class Employee < Person
  protected
  def ssn = @ssn          # re-declared PROTECTED in the subclass
end
class Contractor < Person
  private
  def ssn = @ssn          # re-declared PRIVATE in the subclass
end

pairs = {
  "Person   vs Person    " => [Person.new(1), Person.new(1)],
  "Person   vs Employee  " => [Person.new(1), Employee.new(1)],
  "Employee vs Person    " => [Employee.new(1), Person.new(1)],
  "Employee vs Employee  " => [Employee.new(1), Employee.new(1)],
  "Person   vs Contractor" => [Person.new(1), Contractor.new(1)]
}
pairs.each do |label, (a, b)|
  puts "  #{label} -> #{a.same?(b)}"
rescue NoMethodError => e
  puts "  #{label} -> #{e.class}: #{e.message.lines.first.strip}"
end
puts "-- the fix: do not redeclare the visibility in the subclass --"
class Clean < Person
  def ssn = @ssn          # no visibility keyword: it INHERITS protected? check:
end
puts "  Clean.new(1).respond_to?(:ssn, true) = #{Clean.new(1).respond_to?(:ssn, true)}"
puts "  Person vs Clean -> #{begin
  Person.new(1).same?(Clean.new(1))
rescue NoMethodError => e
  "#{e.class}: #{e.message.lines.first.strip}"
end}"
puts "  (a plain `def` in a subclass is PUBLIC, it does not inherit the parent's visibility)"
puts "  Clean.public_instance_methods(false) = #{Clean.public_instance_methods(false).inspect}"
