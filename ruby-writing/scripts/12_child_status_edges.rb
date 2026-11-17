# frozen_string_literal: true

require "English"
puts "ruby #{RUBY_VERSION}"
puts "-- 1. $CHILD_STATUS before any child has run --"
puts "   #{$CHILD_STATUS.inspect}  -> calling .exitstatus on it would be #{$CHILD_STATUS.nil? ? "NoMethodError on nil" : "fine"}"
puts "-- 2. argv form with a missing command --"
r = system("nosuchcmd-xyz-argv", "arg")
puts "   system returned #{r.inspect}; $CHILD_STATUS = #{$CHILD_STATUS.inspect}"
puts "   exitstatus = #{$CHILD_STATUS&.exitstatus.inspect}"
puts "-- 3. system(..., exception: true) raises instead of returning nil/false --"
begin
  system("nosuchcmd-xyz-argv", exception: true)
rescue Errno::ENOENT => e
  puts "   #{e.class}: #{e.message}"
end
begin
  system("sh", "-c", "exit 3", exception: true)
rescue RuntimeError => e
  puts "   #{e.class}: #{e.message}"
end
puts "-- 4. a signalled child: `exitstatus || FAILED` maps SIGTERM to 1, not 143 --"
system("sh", "-c", "kill -TERM $$")
st = $CHILD_STATUS
puts "   exitstatus=#{st.exitstatus.inspect} termsig=#{st.termsig.inspect}"
puts "   `st.exitstatus || 1`         = #{(st.exitstatus || 1).inspect}"
puts "   shell convention 128+termsig = #{128 + st.termsig}"
puts "   Process::Status#to_i>>8      = #{st.to_i >> 8}"
