# frozen_string_literal: true

require "optparse"
puts "ruby #{RUBY_VERSION} optparse #{OptionParser::Version}"

def build(opts)
  OptionParser.new do |o|
    o.banner = "usage: demo [--json]"
    o.on("--json") { opts[:json] = true }
    o.on("-h", "--help") { opts[:help] = true }
  end
end

puts "-- 1. parse! MUTATES argv and leaves the non-options behind --"
argv = ["--json", "sub", "arg"]
o = {}
rest = build(o).parse!(argv)
puts "   opts=#{o.inspect} argv-after=#{argv.inspect} return=#{rest.inspect} (same object? #{rest.equal?(argv)})"

puts "-- 2. an unknown option raises OptionParser::InvalidOption --"
begin
  build({}).parse!(["--nope"])
rescue OptionParser::InvalidOption => e
  puts "   #{e.class}: #{e.message}; args=#{e.args.inspect}"
end
puts "   OptionParser::ParseError < StandardError = #{OptionParser::ParseError < StandardError}"
puts "   InvalidOption < ParseError = #{OptionParser::InvalidOption < OptionParser::ParseError}"

puts "-- 3. ABBREVIATION is on by default: --js matches --json --"
o = {}
build(o).parse!(["--js"])
puts "   --js -> #{o.inspect}   (a future --jsonl would silently make this ambiguous)"
begin
  p2 = OptionParser.new { |x| x.on("--json") {}; x.on("--jsonl") {} }
  p2.parse!(["--js"])
rescue OptionParser::AmbiguousOption => e
  puts "   after adding --jsonl: #{e.class}: #{e.message}"
end

puts "-- 4. `--` stops option parsing; everything after is positional --"
argv = ["--", "--json"]
o = {}
build(o).parse!(argv)
puts "   opts=#{o.inspect} argv=#{argv.inspect}"

puts "-- 5. order! stops at the first non-option; parse! keeps scanning --"
a1 = ["sub", "--json"]
o1 = {}
build(o1).order!(a1)
puts "   order!: opts=#{o1.inspect} argv=#{a1.inspect}"
a2 = ["sub", "--json"]
o2 = {}
build(o2).parse!(a2)
puts "   parse!: opts=#{o2.inspect} argv=#{a2.inspect}"
puts "   (POSIXLY_CORRECT in ENV makes parse! behave like order!)"

puts "-- 6. `o.on('--json')` with no argument spec yields true, not the string --"
seen = nil
OptionParser.new { |x| x.on("--json") { |v| seen = v } }.parse!(["--json"])
puts "   yielded #{seen.inspect}"
seen = nil
OptionParser.new { |x| x.on("--json VALUE") { |v| seen = v } }.parse!(["--json", "x"])
puts "   with VALUE: #{seen.inspect}"
seen = :unset
OptionParser.new { |x| x.on("--[no-]json") { |v| seen = v } }.parse!(["--no-json"])
puts "   --[no-]json with --no-json: #{seen.inspect}"

puts "-- 7. a handler that raises leaks out of parse! as-is --"
begin
  OptionParser.new { |x| x.on("--boom") { raise ArgumentError, "bad" } }.parse!(["--boom"])
rescue => e
  puts "   #{e.class}: #{e.message} (NOT wrapped in OptionParser::ParseError)"
end
