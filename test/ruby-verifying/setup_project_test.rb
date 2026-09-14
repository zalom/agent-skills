require_relative "test_helper"

class SetupProjectTest < Minitest::Test
  include ProjectFixtures

  PLAIN = {
    "Gemfile" => %(source "https://rubygems.org"\n\ngem "rake"\n),
    ".ruby-version" => "ruby-4.0.3\n",
    "lib/shop.rb" => "class Shop; end\n",
    "test/shop_test.rb" => %(require "test_helper"\nrequire "shop"\n),
    "test/models/cart_test.rb" => %(require 'test_helper'\n),
    ".git/HEAD" => "ref: refs/heads/main\n"
  }.freeze

  RAILS_HELPER = <<~RUBY.freeze
    ENV["RAILS_ENV"] ||= "test"
    require_relative "../config/environment"
    require "rails/test_help"

    module ActiveSupport
      class TestCase
        parallelize(workers: :number_of_processors)

        fixtures :all
      end
    end
  RUBY

  RAILS = {
    "Gemfile" => %(source "https://rubygems.org"\n\ngem "rails", "~> 8.1"\n),
    "config/application.rb" => "",
    "test/test_helper.rb" => RAILS_HELPER,
    "test/models/post_test.rb" => %(require "test_helper"\n),
    ".gitignore" => "/tmp/*\n/log/*",
    ".github/workflows/ci.yml" => "name: CI\n",
    "mise.toml" => %([tools]\nruby = "4.0.3"\n)
  }.freeze

  def setup_project(root, *options)
    out = StringIO.new
    err = StringIO.new
    code = SetupProject.run([*options, root], out: out, err: err)
    [code, out.string, err.string]
  end

  def test_plain_project_gets_the_whole_stack
    in_project(PLAIN) do |root|
      code, out, = setup_project(root)

      assert_equal 0, code
      gemfile = read(root, "Gemfile")
      %w[minitest simplecov mutineer skunk rubycritic flog ostruct].each { |name| assert_match(/gem "#{name}"/, gemfile) }
      assert_includes gemfile, %(gem "rubycritic", "~> 4.12", require: false)
      assert_includes read(root, "test/test_helper.rb"), %(cover "{app,lib,tools}/**/*.rb")
      assert_equal %(require_relative "test_helper"\nrequire "shop"\n), read(root, "test/shop_test.rb")
      assert_equal %(require_relative "../test_helper"\n), read(root, "test/models/cart_test.rb")
      assert File.executable?(File.join(root, "bin/verify-change"))
      assert File.executable?(File.join(root, "bin/crap"))
      assert_equal 11, read(root, ".mutineer.yml").scan(/^  - /).size
      assert_includes read(root, "Rakefile"), "Minitest::TestTask"
      assert_equal "coverage/\n.mutineer/\n", read(root, ".gitignore")
      workflow = read(root, ".github/workflows/ci.yml")
      assert_includes workflow, %(ruby-version: "4.0.3")
      assert_includes workflow, "branches: [main]"
      assert_includes workflow, "run: COVERAGE=1 bundle exec rake test"
      assert_includes workflow, %(run: bundle exec bin/verify-change "$BASE_REF")
      refute_includes workflow, "__"
      assert_includes out, "Next steps:"
    end
  end

  def test_running_twice_changes_nothing
    in_project(PLAIN) do |root|
      setup_project(root)
      snapshot = Dir.glob("**/*", File::FNM_DOTMATCH, base: root).select { |path| File.file?(File.join(root, path)) }.to_h { |path| [path, read(root, path)] }

      _code, out, = setup_project(root)

      snapshot.each { |path, content| assert_equal content, read(root, path), path }
      assert out.lines.grep(/^(created|updated)/).empty?, out
    end
  end

  def test_dry_run_writes_nothing
    in_project(PLAIN) do |root|
      _code, out, = setup_project(root, "--dry-run")

      assert_includes out, "would be created bin/verify-change"
      refute File.exist?(File.join(root, "bin/verify-change"))
      assert_equal PLAIN["Gemfile"], read(root, "Gemfile")
    end
  end

  def test_rails_app_gets_rails_coverage_and_keeps_its_workflow
    in_project(RAILS) do |root|
      code, = setup_project(root)

      assert_equal 0, code
      gemfile = read(root, "Gemfile")
      refute_match(/gem "minitest"/, gemfile)
      assert_includes gemfile, %(gem "mutineer", "~> 1.0", require: false)
      helper = read(root, "test/test_helper.rb")
      assert helper.start_with?(%(if ENV["COVERAGE"]\n  require "simplecov"\n  SimpleCov.start "rails" do))
      assert_includes helper, "    parallelize(workers: :number_of_processors)\n\n    if ENV[\"COVERAGE\"]\n      parallelize_setup"
      assert_equal %(require "test_helper"\n), read(root, "test/models/post_test.rb")
      assert_equal "name: CI\n", read(root, ".github/workflows/ci.yml")
      workflow = read(root, ".github/workflows/verify-change.yml")
      assert_includes workflow, %(run: bin/rails db:test:prepare && bundle exec bin/verify-change "$BASE_REF")
      assert_includes workflow, %(ruby-version: "4.0.3")
      assert_equal "/tmp/*\n/log/*\ncoverage/\n.mutineer/\n", read(root, ".gitignore")
      refute File.exist?(File.join(root, "Rakefile"))
    end
  end

  def test_no_ci_skips_the_workflow
    in_project(PLAIN) do |root|
      setup_project(root, "--no-ci")

      refute File.exist?(File.join(root, ".github/workflows/ci.yml"))
    end
  end

  def test_old_ruby_gets_a_warning_and_still_sets_up
    in_project(PLAIN.merge(".ruby-version" => "3.3.5\n")) do |root|
      code, _out, err = setup_project(root)

      assert_equal 0, code
      assert_includes err, "Ruby 3.3.5: Mutineer needs Ruby 3.4 or later"
    end
  end

  def test_existing_gems_and_coverage_are_kept
    files = PLAIN.merge("Gemfile" => %(source "https://rubygems.org"\ngem "simplecov"\n),
                        "test/test_helper.rb" => %(require "simplecov"\nSimpleCov.start\n))
    in_project(files) do |root|
      setup_project(root)

      assert_equal 1, read(root, "Gemfile").scan(/gem "simplecov"/).size
      assert_equal %(require "simplecov"\nSimpleCov.start\n), read(root, "test/test_helper.rb")
    end
  end

  def test_a_directory_without_a_gemfile_exits_two
    in_project("README.md" => "") do |root|
      code, _out, err = setup_project(root)

      assert_equal 2, code
      assert_includes err, "has no Gemfile"
    end
  end

  def test_usage_errors_exit_one
    assert_equal 1, SetupProject.run([], out: StringIO.new, err: StringIO.new)
    assert_equal 1, SetupProject.run(["--force", "."], out: StringIO.new, err: StringIO.new)
    assert_equal 0, SetupProject.run(["--help"], out: StringIO.new, err: StringIO.new)
  end

  def test_an_existing_minitest_helper_gets_the_plain_coverage_block
    in_project(PLAIN.merge("test/test_helper.rb" => %(require "minitest/autorun"\n))) do |root|
      setup_project(root, "--no-ci")

      coverage = %(if ENV["COVERAGE"]\n  require "simplecov"\n  SimpleCov.start do\n    enable_coverage :branch\n    skip "/test/"\n    cover "{app,lib,tools}/**/*.rb"\n  end\nend\n\n)
      assert_equal %(#{coverage}require "minitest/autorun"\n), read(root, "test/test_helper.rb")
    end
  end
end
