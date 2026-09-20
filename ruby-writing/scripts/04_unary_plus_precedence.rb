# frozen_string_literal: true

puts "claim: +\"str\".method parses as +(\"str\".method), so the unary plus does NOT unfreeze the receiver of the method. Under frozen_string_literal this raises FrozenError."
puts "ruby #{RUBY_VERSION}"
begin
  +"ab".sub!(/z/, "")
rescue FrozenError => e
  puts "+\"ab\".sub!(...)   -> #{e.class}: #{e.message}"
end
puts "(+\"ab\").sub!(...)  -> #{(+"ab").sub!(/z/, "").inspect}"
puts "(+\"ab\").frozen?    -> #{(+"ab").frozen?}"
puts "\"ab\".frozen?       -> #{"ab".frozen?}"
puts "\"a#{1}b\".frozen?   -> #{"a#{1}b".frozen?}   (interpolated literals are NOT frozen)"
puts "String.new(\"ab\").frozen? -> #{String.new("ab").frozen?}"
puts "-- dup vs +@ on an already-mutable string --"
s = String.new("x")
puts "  (+s).equal?(s) -> #{(+s).equal?(s)}   (+@ returns self when already mutable; dup always copies)"
puts "  s.dup.equal?(s) -> #{s.dup.equal?(s)}"
