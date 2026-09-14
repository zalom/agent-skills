require_relative "test_helper"

class VerifyChangeTest < Minitest::Test
  include ProjectFixtures

  Status = Struct.new(:success) do
    def success? = success
  end

  def git_stub(merge_base: "abc123", changed: [], untracked: [], refs: %w[main])
    lambda do |*args|
      case args.first
      when "rev-parse" then ["", Status.new(refs.include?(args.last))]
      when "merge-base" then merge_base ? ["#{merge_base}\n", Status.new(true)] : ["fatal: no such ref\n", Status.new(false)]
      when "diff" then [changed.join("\n"), Status.new(true)]
      when "ls-files" then [untracked.join("\n"), Status.new(true)]
      end
    end
  end

  def verify(root, argv, **git)
    out = StringIO.new
    err = StringIO.new
    commands = []
    runner = ->(env, command) { commands << [env, command]; true }
    code = VerifyChange.new(argv, root: root, out: out, err: err, git: git_stub(**git), run: runner).call
    [code, out.string, err.string, commands]
  end

  def test_maps_sources_to_their_conventional_test_files
    assert_equal ["test/models/order_test.rb"], VerifyChange.test_candidates("app/models/order.rb")
    assert_equal ["test/shop/cart_test.rb", "test/lib/shop/cart_test.rb"], VerifyChange.test_candidates("lib/shop/cart.rb")
    assert_equal ["test/tools/crap_test.rb"], VerifyChange.test_candidates("tools/crap.rb")
    assert_empty VerifyChange.test_candidates("config/routes.rb")
  end

  def test_plain_project_runs_all_four_checks_on_the_merge_base
    files = { "lib/refund.rb" => "", "test/refund_test.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      code, out, _err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      assert_equal 0, code
      assert_includes out, "Change verified"
      tests, patch, mutation, crap = commands.map(&:last)
      assert_equal({ "COVERAGE" => "1" }, commands.first.first)
      assert_equal "test/refund_test.rb", tests.last
      assert_equal %w[bundle exec simplecov patch --base abc123 --minimum 100], patch
      assert_equal %w[bundle exec mutineer run lib/refund.rb --test test/refund_test.rb --since abc123 --threshold 75 --strategy redefine], mutation
      assert_equal %w[bundle exec bin/crap --threshold 30 --since abc123 lib/refund.rb], crap
    end
  end

  def test_rails_app_uses_the_rails_runner_and_boot_mode
    files = { "config/application.rb" => "", "app/models/post.rb" => "", "test/models/post_test.rb" => "",
              "test/integration/publishing_test.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      _code, _out, _err, commands = verify(root, ["main", "--test", "test/integration/publishing_test.rb"], changed: ["app/models/post.rb"])

      assert_equal %w[bin/rails test test/models/post_test.rb test/integration/publishing_test.rb], commands.first.last
      assert_equal "--rails", commands[2].last.last
      assert_includes commands[2].last, "test/integration/publishing_test.rb"
    end
  end

  def test_a_source_without_a_test_fails_before_running_anything
    in_project("lib/refund.rb" => "", ".mutineer.yml" => "") do |root|
      code, _out, err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      assert_equal 1, code
      assert_includes err, "No test file found for: lib/refund.rb"
      assert_empty commands
    end
  end

  def test_a_changed_test_counts_as_covering_an_unmapped_source
    files = { "lib/money/rounding.rb" => "", "test/checkout_test.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      code, _out, _err, commands = verify(root, ["main"], changed: ["lib/money/rounding.rb", "test/checkout_test.rb"])

      assert_equal 0, code
      assert_equal 4, commands.size
    end
  end

  def test_a_test_only_change_runs_the_tests_alone
    in_project("test/refund_test.rb" => "") do |root|
      _code, _out, _err, commands = verify(root, ["main"], changed: ["test/refund_test.rb"])

      assert_equal 1, commands.size
    end
  end

  def test_failed_checks_are_named_and_exit_one
    files = { "lib/refund.rb" => "", "test/refund_test.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      out = StringIO.new
      runner = ->(_env, command) { !command.include?("mutineer") }
      code = VerifyChange.new(["main"], root: root, out: out, err: StringIO.new, git: git_stub(changed: ["lib/refund.rb"]), run: runner).call

      assert_equal 1, code
      assert_includes out.string, "Failed: Mutation testing"
    end
  end

  def test_red_tests_stop_the_other_checks
    files = { "lib/refund.rb" => "", "test/refund_test.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      out = StringIO.new
      commands = []
      runner = ->(_env, command) { commands << command; false }
      code = VerifyChange.new(["main"], root: root, out: out, err: StringIO.new, git: git_stub(changed: ["lib/refund.rb"]), run: runner).call

      assert_equal 1, code
      assert_equal 1, commands.size
      assert_includes out.string, "a failing test kills every mutant"
      assert_includes out.string, "Failed: Tests with coverage"
    end
  end

  def test_nothing_changed_passes
    in_project({}) do |root|
      code, out, _err, commands = verify(root, [])

      assert_equal 0, code
      assert_includes out, "No changed Ruby files since main."
      assert_empty commands
    end
  end

  def test_default_base_prefers_origin_main
    in_project({}) do |root|
      _code, out, = verify(root, [], refs: %w[origin/main main])

      assert_includes out, "since origin/main"
    end
  end

  def test_untracked_files_and_a_missing_mutineer_config_are_reported
    in_project("lib/refund.rb" => "", "test/refund_test.rb" => "") do |root|
      _code, _out, err, = verify(root, ["main"], changed: ["lib/refund.rb"], untracked: ["lib/new_policy.rb"])

      assert_includes err, "run git add first): lib/new_policy.rb"
      assert_includes err, "Missing .mutineer.yml"
    end
  end

  def test_a_missing_mutineer_config_passes_all_operators_on_the_command_line
    in_project("lib/refund.rb" => "", "test/refund_test.rb" => "") do |root|
      _code, _out, err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      mutation = commands[2].last
      assert_equal ["--operators", VerifyChange::ALL_OPERATORS.join(",")], mutation.last(2)
      assert_includes err, "Missing .mutineer.yml"
    end
  end

  def test_all_operators_matches_the_mutineer_yml_asset
    operators = YAML.load_file(File.join(SKILL_ROOT, "assets/mutineer.yml")).fetch("operators")

    assert_equal operators, VerifyChange::ALL_OPERATORS
  end

  def test_an_unknown_base_exits_two
    in_project({}) do |root|
      code, _out, err, = verify(root, ["nope"], merge_base: nil)

      assert_equal 2, code
      assert_includes err, "Cannot find the merge base of nope and HEAD"
    end
  end

  def test_bad_arguments_print_usage_and_exit_two
    in_project({}) do |root|
      assert_equal 2, verify(root, ["main", "extra"]).first
      assert_equal 2, verify(root, ["--test"]).first
      assert_equal 0, verify(root, ["--help"]).first
    end
  end
end
