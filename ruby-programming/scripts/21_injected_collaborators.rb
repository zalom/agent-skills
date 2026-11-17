# frozen_string_literal: true

puts "claim: a collaborator passed in with a production default lets a caller replace it"
puts "claim: state held on the class leaks from one caller to the next"
puts "claim: fetch names a missing key, and Data names a missing member"

def check(label, ok)
  puts "  #{ok ? 'ok  ' : 'FAIL'} #{label}"
  exit 1 unless ok
end

class Stamp
  def initialize(clock: Time)
    @clock = clock
  end

  def call = @clock.now.year
end

fixed = Struct.new(:now).new(Time.new(2026, 11, 17))
check "the default reads the real clock", Stamp.new.call == Time.now.year
check "a passed clock replaces it", Stamp.new(clock: fixed).call == 2026

class SharedStore
  def self.rows = (@rows ||= [])
end

class OwnStore
  def initialize(rows: [])
    @rows = rows
  end

  attr_reader :rows
end

SharedStore.rows << :first_caller
check "wrong form: the second caller sees the first caller's row", SharedStore.rows == [:first_caller]
OwnStore.new.rows << :first_caller
check "an instance starts clean for every caller", OwnStore.new.rows.empty?

missing = begin
  { name: "plastic" }.fetch(:api_key)
rescue KeyError => e
  e.message
end
check "fetch raises KeyError that names the key", missing.include?("api_key")
check "[] returns nil and names nothing", { name: "plastic" }[:api_key].nil?

Result = Data.define(:status, :reference)
member = begin
  Result.new(status: :declined)
rescue ArgumentError => e
  e.message
end
check "Data names the missing member", member.include?("reference")
