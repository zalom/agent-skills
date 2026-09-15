require "minitest/test_task"

Minitest::TestTask.create(:test) do |task|
  task.libs << "plain-writing/hooks"
  task.test_globs = [
    "test/**/*_test.rb",
    "ruby-quality-checking/assets/test/**/*_test.rb",
    "plain-writing/hooks/test/**/*_test.rb"
  ]
end

task default: :test
