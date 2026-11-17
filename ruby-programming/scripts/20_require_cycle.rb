# frozen_string_literal: true

require "open3"
require "tmpdir"

puts "claim: two files that require each other make ruby -w print a circular require warning"
puts "claim: when the lower file requires nothing above it, the warning goes away"

def check(label, ok)
  puts "  #{ok ? 'ok  ' : 'FAIL'} #{label}"
  exit 1 unless ok
end

def warnings(files)
  Dir.mktmpdir do |dir|
    files.each { |name, body| File.write(File.join(dir, name), body) }
    _out, err, _status = Open3.capture3("ruby", "-w", "-I", dir, "-e", 'require "store"')
    err
  end
end

cycle = warnings(
  "store.rb" => "require \"record\"\nmodule Store; Error = Class.new(StandardError); end\n",
  "record.rb" => "require \"store\"\nmodule Record; end\n"
)
check "a cycle warns under ruby -w", cycle.include?("circular require considered harmful")

layered = warnings(
  "store.rb" => "require \"errors\"\nrequire \"record\"\nmodule Store; end\n",
  "record.rb" => "require \"errors\"\nmodule Record; end\n",
  "errors.rb" => "module Errors; Error = Class.new(StandardError); end\n"
)
check "the shared error in a lower file ends the warning", !layered.include?("circular require")
