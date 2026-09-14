require_relative "test_helper"

class LintStepTest < Minitest::Test
  include ProjectFixtures

  Status = Struct.new(:success) do
    def success? = success
  end

  def git_stub(changed:, merge_base: "abc123")
    lambda do |*args|
      case args.first
      when "merge-base" then [merge_base ? "#{merge_base}\n" : "no ref\n", Status.new(!!merge_base)]
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
    code = VerifyChange.new(argv, root: root, out: out, err: err, git: git_stub(changed: changed), run: runner).call
    [code, out.string, err.string, commands]
  end

  def test_standard_wired_through_rubocop_yml_runs_rubocop_not_standardrb
    files = { ".rubocop.yml" => "plugins:\n  - standard\n", "Gemfile.lock" => "DEPENDENCIES\n  standard (~> 1.0)\n",
              "lib/refund.rb" => "", "test/refund_test.rb" => "" }
    in_project(files) do |root|
      _code, _out, _err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      lint = commands.first.last
      assert_equal %w[bundle exec rubocop --force-exclusion lib/refund.rb], lint
    end
  end

  def test_style_guide_without_the_gem_in_the_lockfile_skips_and_names_it
    files = { ".rubocop.yml" => "", "lib/refund.rb" => "", "test/refund_test.rb" => "" }
    in_project(files) do |root|
      _code, out, _err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      refute_equal %w[bundle exec rubocop --force-exclusion lib/refund.rb], commands.first&.last
      assert_includes out, "Lint skipped"
      assert_includes out, "rubocop"
    end
  end

  def test_a_change_only_to_a_migration_is_linted
    files = { ".rubocop.yml" => "", "Gemfile.lock" => "DEPENDENCIES\n  rubocop (~> 1.0)\n",
              "db/migrate/20260101_create_widgets.rb" => "" }
    in_project(files) do |root|
      _code, out, _err, commands = verify(root, ["main"], changed: ["db/migrate/20260101_create_widgets.rb"])

      lint = commands.first.last
      assert_equal %w[bundle exec rubocop --force-exclusion db/migrate/20260101_create_widgets.rb], lint
      refute_includes out, "No changed Ruby files"
    end
  end

  def test_lint_runs_before_the_untested_source_check
    files = { ".rubocop.yml" => "", "Gemfile.lock" => "DEPENDENCIES\n  rubocop (~> 1.0)\n", "lib/refund.rb" => "" }
    in_project(files) do |root|
      code, _out, err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      assert_equal 1, code
      assert_includes err, "No test file found for: lib/refund.rb"
      assert_empty commands
    end
  end

  def test_two_style_guides_skips_lint_with_a_line_naming_them
    files = { ".standard.yml" => "", ".rubocop.yml" => "require:\n  - rubocop-rails\n",
              "Gemfile.lock" => "DEPENDENCIES\n  rubocop (~> 1.0)\n  standard (~> 1.0)\n",
              "lib/refund.rb" => "", "test/refund_test.rb" => "" }
    in_project(files) do |root|
      code, out, _err, commands = verify(root, ["main"], changed: ["lib/refund.rb"])

      refute_equal %w[bundle exec rubocop --force-exclusion lib/refund.rb], commands.first&.last
      refute_equal %w[bundle exec standardrb --force-exclusion lib/refund.rb], commands.first&.last
      assert_includes out, "Lint skipped"
      assert_includes out, "two style guides"
      assert_equal 0, code
    end
  end

  def test_a_lint_failure_is_reported_but_does_not_stop_later_steps
    files = { ".rubocop.yml" => "", "Gemfile.lock" => "DEPENDENCIES\n  rubocop (~> 1.0)\n",
              "lib/refund.rb" => "", "test/refund_test.rb" => "", ".mutineer.yml" => "" }
    in_project(files) do |root|
      out = StringIO.new
      commands = []
      runner = ->(_env, command) { commands << command; !command.first(2).eql?(%w[bundle exec]) || command[2] != "rubocop" }
      code = VerifyChange.new(["main"], root: root, out: out, err: StringIO.new, git: git_stub(changed: ["lib/refund.rb"]), run: runner).call

      assert_equal 1, code
      assert_operator commands.size, :>, 1
      assert_includes out.string, "Failed: Lint"
    end
  end
end
