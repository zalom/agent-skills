require "minitest/test_task"

Minitest::TestTask.create(:test) do |task|
  task.libs << "writing-style/hooks"
  task.test_globs = [
    "test/**/*_test.rb",
    "writing-style/hooks/test/**/*_test.rb"
  ]
end

task default: :test
