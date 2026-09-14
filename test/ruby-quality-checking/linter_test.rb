require_relative "test_helper"

class LinterTest < Minitest::Test
  include ProjectFixtures

  PLAIN = { "Gemfile" => %(source "https://rubygems.org"\n\ngem "rake"\n), "lib/shop.rb" => "class Shop; end\n" }.freeze

  def setup_project(root, *options)
    out = StringIO.new
    err = StringIO.new
    code = SetupProject.run([*options, root], out: out, err: err)
    [code, out.string, err.string]
  end

  def test_linter_standard_with_a_directory_argument_parses_as_one_path_not_two
    in_project(PLAIN) do |root|
      code, _out, err = setup_project(root, "--linter", "standard")

      assert_equal 0, code, err
    end
  end

  def test_linter_standard_installs_the_gem_and_config
    in_project(PLAIN) do |root|
      code, = setup_project(root, "--linter", "standard")

      assert_equal 0, code
      assert_match(/gem "standard"/, read(root, "Gemfile"))
      assert File.exist?(File.join(root, ".standard.yml"))
    end
  end

  def test_linter_equals_form_installs_omakase
    in_project(PLAIN) do |root|
      code, = setup_project(root, "--linter=omakase")

      assert_equal 0, code
      assert_match(/gem "rubocop-rails-omakase"/, read(root, "Gemfile"))
      assert File.exist?(File.join(root, ".rubocop.yml"))
    end
  end

  def test_linter_with_an_unknown_value_exits_one
    in_project(PLAIN) do |root|
      code, _out, _err = setup_project(root, "--linter", "eslint")

      assert_equal 1, code
    end
  end

  def test_linter_with_no_value_exits_one
    in_project(PLAIN) do |root|
      code, = setup_project(root, "--linter")

      assert_equal 1, code
    end
  end

  def test_dry_run_with_linter_writes_nothing
    in_project(PLAIN) do |root|
      _code, out, = setup_project(root, "--dry-run", "--linter", "omakase")

      refute File.exist?(File.join(root, ".rubocop.yml"))
      assert_equal PLAIN["Gemfile"], read(root, "Gemfile")
      assert_includes out, "would be created .rubocop.yml"
    end
  end

  def test_a_second_linter_run_before_bundle_install_keeps_it_quietly
    in_project(PLAIN) do |root|
      setup_project(root, "--linter", "standard")
      gemfile_after_first = read(root, "Gemfile")

      _code, _out, err = setup_project(root, "--linter", "standard")

      assert_empty err
      assert_equal gemfile_after_first, read(root, "Gemfile")
      assert_equal 1, gemfile_after_first.scan(/gem "standard"/).size
    end
  end

  def test_linter_on_a_project_with_a_different_style_guide_warns_and_keeps_it
    files = PLAIN.merge(".rubocop.yml" => "")
    in_project(files) do |root|
      _code, _out, err = setup_project(root, "--linter", "standard")

      assert_includes err, "already set up"
      refute File.exist?(File.join(root, ".standard.yml"))
    end
  end

  def test_ambiguous_style_guide_warns_and_does_not_stop_setup
    files = PLAIN.merge(".standard.yml" => "", ".rubocop.yml" => "require:\n  - rubocop-rails\n")
    in_project(files) do |root|
      code, _out, err = setup_project(root)

      assert_equal 0, code
      assert_includes err, "Two style guides"
      assert_equal "", read(root, ".standard.yml")
    end
  end

  def test_linter_on_a_gem_only_style_guide_installs_the_missing_config_file
    files = PLAIN.merge("Gemfile" => %(source "https://rubygems.org"\n\ngem "rake"\ngem "rubocop"\n))
    in_project(files) do |root|
      code, out, = setup_project(root, "--linter", "rubocop")

      assert_equal 0, code
      assert File.exist?(File.join(root, ".rubocop.yml"))
      assert_equal 1, read(root, "Gemfile").scan(/gem "rubocop"/).size
      refute_includes out, "kept    .rubocop.yml"
    end
  end

  def test_no_style_guide_and_no_linter_flag_prints_choices_and_installs_nothing
    in_project(PLAIN) do |root|
      _code, out, = setup_project(root, "--no-ci")

      assert_includes out, "omakase"
      assert_includes out, "standard"
      refute File.exist?(File.join(root, ".rubocop.yml"))
      refute File.exist?(File.join(root, ".standard.yml"))
    end
  end
end
