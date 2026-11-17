# frozen_string_literal: true

require "tmpdir"
require "open3"
require "English"
puts "ruby #{RUBY_VERSION}"

puts "-- 1. $stdout is reassignable; STDOUT is a constant --"
require "stringio"
buf = StringIO.new
old = $stdout
$stdout = buf
puts "captured"
$stdout = old
puts "   $stdout captured: #{buf.string.inspect}"
puts "   STDOUT.equal?($stdout) = #{STDOUT.equal?($stdout)} (true only while nothing reassigned it)"
begin
  STDOUT = STDERR
rescue => e
  puts "   reassigning STDOUT: #{e.class}"
end

puts "-- 2. Kernel#system with one string goes through the shell; an array form does not --"
Dir.mktmpdir do |dir|
  victim = File.join(dir, "victim")
  File.write(victim, "x")
  name = "#{victim}; echo PWNED"
  system("ls #{name} > /dev/null 2>&1")
  puts "   one string, shell expands `;`  -> exitstatus #{$CHILD_STATUS.exitstatus}"
  out, = Open3.capture2e("ls", name)
  puts "   argv form, no shell            -> #{out.strip.inspect}"
end

puts "-- 3. system returns true/false/nil; the STATUS is a separate global --"
puts "   system('true')    -> #{system("true").inspect}, exitstatus #{$CHILD_STATUS.exitstatus}"
puts "   system('exit 3')  -> #{system("exit 3").inspect}, exitstatus #{$CHILD_STATUS.exitstatus}"
puts "   system('nosuchcmd-xyz') -> #{system("nosuchcmd-xyz", err: File::NULL).inspect} (nil: could not run)"
puts "   after a failure to launch, $CHILD_STATUS = #{$CHILD_STATUS.inspect}"
puts "   $CHILD_STATUS.exitstatus is nil when the child was SIGNALLED:"
system("kill -TERM $$")
puts "     exitstatus=#{$CHILD_STATUS.exitstatus.inspect} signaled?=#{$CHILD_STATUS.signaled?} termsig=#{$CHILD_STATUS.termsig.inspect}"
puts "   Open3 returns the status as a value, no global:"
_o, _e, st = Open3.capture3("sh", "-c", "exit 3")
puts "     #{st.exitstatus}"

puts "-- 4. $? is thread-local and fiber-local --"
system("true")
t = Thread.new { system("exit 7"); $CHILD_STATUS.exitstatus }
puts "   in thread: #{t.value}, in main after: #{$CHILD_STATUS.exitstatus}"

puts "-- 5. Dir.glob order is NOT sorted by default on every platform; sort: is the contract --"
Dir.mktmpdir do |dir|
  %w[b10 b9 a].each { |n| File.write(File.join(dir, n), "") }
  puts "   Dir.glob(default) = #{Dir.glob(File.join(dir, "*")).map { File.basename(_1) }.inspect}"
  puts "   Dir.glob(sort:false) = #{Dir.glob(File.join(dir, "*"), sort: false).map { File.basename(_1) }.inspect}"
  puts "   NOTE: the sort is byte order, so b10 sorts before b9."
  puts "   Dir.glob with a brace/char class needs File::FNM_EXTGLOB for {a,b}:"
  puts "   #{Dir.glob(File.join(dir, "{a,b9}")).map { File.basename(_1) }.inspect}"
end

puts "-- 6. File.write is NOT atomic; a rename on the same filesystem is --"
Dir.mktmpdir do |dir|
  path = File.join(dir, "f")
  tmp = "#{path}.tmp.#{Process.pid}"
  File.write(tmp, "new")
  File.rename(tmp, path)
  puts "   wrote via rename: #{File.read(path).inspect}; leftovers: #{Dir.children(dir).inspect}"
  puts "   File.write truncates first, so a crash mid-write leaves a SHORT file."
end

puts "-- 7. Timeout.timeout raises inside whatever line is running --"
require "timeout"
begin
  Timeout.timeout(0.05) do
    begin
      sleep 1
    ensure
      puts "   the ensure still runs, but it ran with the timeout already pending"
    end
  end
rescue Timeout::Error => e
  puts "   #{e.class}: #{e.message}"
end
puts "   Timeout::Error < StandardError = #{Timeout::Error < StandardError}, so a bare rescue eats it"
