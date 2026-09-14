require_relative "test_helper"
require "json"

class DetectToolsTest < Minitest::Test
  include ProjectFixtures

  def run_detect(root, *args)
    Open3.capture3(RbConfig.ruby, DETECT_TOOLS, *args, root)
  end

  def test_a_directory_without_a_gemfile_still_reports_and_exits_zero
    in_project("lib/shop.rb" => "class Shop; end\n") do |root|
      out, _err, status = run_detect(root)

      assert status.success?
      assert_includes out, "Missing:"
      assert_includes out, "a Gemfile"
    end
  end

  def test_a_rails_app_on_postgresql_names_what_to_start
    files = { "config/application.rb" => "", "test/test_helper.rb" => "", "config/database.yml" => "test:\n  adapter: postgresql\n" }
    in_project(files) do |root|
      out, _err, status = run_detect(root)

      assert status.success?
      assert_includes out, "bin/rails db:test:prepare"
      assert_includes out, "postgresql"
    end
  end

  def test_both_frameworks_are_listed_and_the_primary_is_named
    files = { "test/test_helper.rb" => "", ".rspec" => "", "spec/spec_helper.rb" => "" }
    in_project(files) do |root|
      out, _err, status = run_detect(root)

      assert status.success?
      assert_includes out, "minitest"
      assert_includes out, "rspec"
      assert_includes out, "Primary: rspec"
    end
  end

  def test_json_output_parses
    in_project("test/test_helper.rb" => "") do |root|
      out, _err, status = run_detect(root, "--json")

      assert status.success?
      parsed = JSON.parse(out)
      assert_equal ["minitest"], parsed["frameworks"]
    end
  end

  def test_a_path_that_is_not_a_directory_exits_two
    Dir.mktmpdir do |root|
      missing = File.join(root, "nope")
      _out, _err, status = run_detect(missing)

      assert_equal 2, status.exitstatus
    end
  end
end
