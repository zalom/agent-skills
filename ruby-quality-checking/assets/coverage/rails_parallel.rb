
if ENV["COVERAGE"]
  parallelize_setup { |worker| SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}" }
  parallelize_teardown { |_worker| SimpleCov.result }
end
