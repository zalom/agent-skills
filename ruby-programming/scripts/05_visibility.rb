# frozen_string_literal: true

puts "claim: protected only buys cross-object calls inside one class family, and a subclass that re-declares the method private breaks the parent's call (bug 13804)."
puts "ruby #{RUBY_VERSION}"

puts "-- 1. private allows self-calls, forbids an explicit receiver on another object --"
class Account
  def initialize(cents) = @cents = cents
  def richer_than?(other) = balance > other.balance   # needs OTHER's balance
  def report = "#{balance} cents"                     # only needs OWN balance
  private
  def balance = @cents
end
puts "  report (own state, private is enough): #{Account.new(10).report}"
begin
  Account.new(10).richer_than?(Account.new(5))
rescue NoMethodError => e
  puts "  richer_than? with private: #{e.class}: #{e.message.lines.first.strip}"
end

puts "-- 2. private DOES allow `self.` on a setter, and since 2.7 on any self-call --"
class Setter
  def bump = (self.value = 1)
  def peek = self.value
  private
  attr_accessor :value
end
puts "  self.value = 1 works: #{Setter.new.bump.inspect}"
puts "  self.value reader works (2.7+): #{Setter.new.peek.inspect}"

puts "-- 3. protected makes the cross-object call work --"
class Protected
  def initialize(cents) = @cents = cents
  def richer_than?(other) = balance > other.balance
  protected
  def balance = @cents
end
puts "  #{Protected.new(10).richer_than?(Protected.new(5))}"

puts "-- 4. bug 13804: a subclass re-declaring the method private breaks the PARENT's call --"
class Child < Protected
  private
  def balance = @cents
end
begin
  puts Protected.new(10).richer_than?(Child.new(5))
rescue NoMethodError => e
  puts "  parent calling into a private subclass override: #{e.class}: #{e.message.lines.first.strip}"
end

puts "-- 5. private_constant --"
module Config
  SECRET = "s"
  private_constant :SECRET
  def self.peek = SECRET
end
puts "  inside:  #{Config.peek}"
begin
  Config::SECRET
rescue NameError => e
  puts "  outside: #{e.class}: #{e.message}"
end

puts "-- 6. private with an inline def returns the method name (3.0+), so it chains --"
class Inline
  private def hidden = 1
end
puts "  Inline.private_instance_methods(false) = #{Inline.private_instance_methods(false).inspect}"
puts "  `private` with no args returns #{class C; p private; end rescue nil}"

puts "-- 7. send bypasses both --"
puts "  Account.new(7).send(:balance) = #{Account.new(7).send(:balance)}"
puts "  protected is reachable by send too: #{Protected.new(7).send(:balance)}"
