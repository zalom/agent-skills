require_relative "test_helper"

class RSpecVerifyChangeTest < Minitest::Test
  include ProjectFixtures

  Status = Struct.new(:success) do
    def success? = success
  end

  LOCKFILE = "GEM\n  specs:\n    rspec-core (3.13.6)\n\nDEPENDENCIES\n  rspec (~> 3.13)\n".freeze

  def git_stub(changed)
    lambda do |*args|
      case args.first
      when "merge-base" then ["abc123\n", Status.new(true)]
      when "diff" then [changed.join("\n"), Status.new(true)]
      when "ls-files" then ["", Status.new(true)]
      end
    end
  end

  def verify(root, argv, changed:)
    out = StringIO.new
    err = StringIO.new
    commands = []
    runner = ->(env, command) { commands << [env, command]; true }
    code = VerifyChange.new(argv, root: root, out: out, err: err, git: git_stub(changed), run: runner).call
    [code, out.string, err.string, commands]
  end

  def test_maps_sources_to_their_conventional_spec_files
    assert_equal ["spec/models/order_spec.rb"], VerifyChange.test_candidates("app/models/order.rb", VerifyChange::RSPEC)
    assert_equal ["spec/shop/cart_spec.rb", "spec/lib/shop/cart_spec.rb"], VerifyChange.test_candidates("lib/shop/cart.rb", VerifyChange::RSPEC)
    assert_equal ["spec/tools/crap_spec.rb"], VerifyChange.test_candidates("tools/crap.rb", VerifyChange::RSPEC)
    assert_empty VerifyChange.test_candidates("config/routes.rb", VerifyChange::RSPEC)
  end

  def test_both_scripts_share_one_rspec_dependency_pattern
    assert_equal SetupProject::RSPEC_DEPENDENCY, VerifyChange::RSPEC_DEPENDENCY
    ["  rspec (~> 3.13)", "  rspec!", "  rspec", "  rspec-core (~> 3.13)", "  rspec-rails (~> 8.0)"].each do |line|
      assert_match VerifyChange::RSPEC_DEPENDENCY, line
    end
    ["  rspec-expectations (~> 3.13)", "  rspec-mocks", "  rspec-support", "    rspec-core (3.13.6)", "  rspecial"].each do |line|
      refute_match VerifyChange::RSPEC_DEPENDENCY, line
    end
  end

  def test_rspec_project_runs_the_specs_and_names_the_framework
    files = { ".rspec" => "--require spec_helper\n", "lib/refund.rb" => "", "spec/refund_spec.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      code, out, err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      assert_equal 0, code
      assert_empty err
      assert_includes out, "Change verified"
      tests, patch, mutation, crap = commands
      assert_equal [{ "COVERAGE" => "1" }, %w[bundle exec rspec spec/refund_spec.rb]], tests
      assert_equal %w[bundle exec simplecov patch --base abc123 --minimum 100], patch.last
      assert_equal %w[bundle exec mutineer run lib/refund.rb --test spec/refund_spec.rb --since abc123 --threshold 75 --framework rspec --strategy redefine], mutation.last
      assert_equal %w[bundle exec bin/crap --threshold 30 --since abc123 lib/refund.rb], crap.last
    end
  end

  def test_rspec_in_the_lockfile_finds_a_spec_under_spec_lib
    files = { "Gemfile.lock" => LOCKFILE, "lib/shop/cart.rb" => "", "spec/lib/shop/cart_spec.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      _code, _out, _err, commands = verify(root, ["main"], changed: ["lib/shop/cart.rb"])

      assert_equal %w[bundle exec rspec spec/lib/shop/cart_spec.rb], commands.first.last
    end
  end

  def test_a_transitive_rspec_in_the_lockfile_keeps_minitest
    files = { "Gemfile.lock" => "GEM\n  specs:\n    rspec-core (3.13.6)\n\nDEPENDENCIES\n  minitest (~> 6.0)\n",
              "lib/refund.rb" => "", "test/refund_test.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      _code, _out, _err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      assert_equal %w[bundle exec ruby], commands.first.last.first(3)
      refute_includes commands[2].last, "--framework"
    end
  end

  def test_a_direct_rspec_expectations_dependency_keeps_minitest
    files = { "Gemfile.lock" => "GEM\n  specs:\n    rspec-expectations (3.13.5)\n\nDEPENDENCIES\n  minitest (~> 6.0)\n  rspec-expectations (~> 3.13)\n",
              "lib/refund.rb" => "", "test/refund_test.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      _code, _out, _err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      assert_equal "test/refund_test.rb", commands.first.last.last
      refute_includes commands[2].last, "--framework"
    end
  end

  def test_both_test_and_spec_folders_are_reported
    files = { ".rspec" => "", "lib/refund.rb" => "", "spec/refund_spec.rb" => "", "test/legacy_test.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      _code, _out, err, commands = verify(root, ["main"], changed: ["lib/refund.rb", "test/legacy_test.rb"])

      assert_includes err, "Both test/ and spec/ exist. Checking with RSpec only, so changed files under test/ do not run."
      assert_equal %w[bundle exec rspec spec/refund_spec.rb], commands.first.last
    end
  end

  def test_rails_rspec_app_runs_rspec_in_rails_boot_mode
    files = { "config/application.rb" => "", ".rspec" => "", "app/models/post.rb" => "", "spec/models/post_spec.rb" => "",
              "spec/requests/publishing_spec.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      _code, _out, _err, commands = verify(root, ["main", "--test", "spec/requests/publishing_spec.rb"], changed: ["app/models/post.rb"])

      assert_equal %w[bundle exec rspec spec/models/post_spec.rb spec/requests/publishing_spec.rb], commands.first.last
      assert_equal %w[--framework rspec --rails], commands[2].last.last(3)
    end
  end

  def test_a_source_without_a_spec_fails_before_running_anything
    in_project("Gemfile.lock" => LOCKFILE, "lib/refund.rb" => "", ".mutineer.yml" => "") do |root|
      code, _out, err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      assert_equal 1, code
      assert_includes err, "No test file found for: lib/refund.rb"
      assert_empty commands
    end
  end

  def test_a_changed_spec_counts_as_covering_an_unmapped_source
    files = { "Gemfile.lock" => LOCKFILE, "lib/money/rounding.rb" => "", "spec/checkout_spec.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      code, _out, _err, commands = verify(root, ["main"], changed: ["lib/money/rounding.rb", "spec/checkout_spec.rb"])

      assert_equal 0, code
      assert_equal %w[bundle exec rspec spec/checkout_spec.rb], commands.first.last
      assert_equal 4, commands.size
    end
  end
end
