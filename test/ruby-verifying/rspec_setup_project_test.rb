require_relative "test_helper"

class RSpecSetupProjectTest < Minitest::Test
  include ProjectFixtures

  SPEC_HELPER = <<~RUBY.freeze
    RSpec.configure do |config|
      config.disable_monkey_patching!
    end
  RUBY

  RSPEC = {
    "Gemfile" => %(source "https://rubygems.org"\n\ngem "rspec", "~> 3.13"\n),
    ".rspec" => "--require spec_helper\n",
    ".ruby-version" => "4.0.3\n",
    "lib/shop.rb" => "class Shop; end\n",
    "spec/spec_helper.rb" => SPEC_HELPER,
    "spec/shop_spec.rb" => %(require "spec_helper"\nrequire "shop"\n),
    ".git/HEAD" => "ref: refs/heads/main\n"
  }.freeze

  RAILS_HELPER = <<~RUBY.freeze
    require "spec_helper"
    ENV["RAILS_ENV"] ||= "test"
    require_relative "../config/environment"
    require "rspec/rails"
  RUBY

  RAILS_RSPEC = {
    "Gemfile" => %(source "https://rubygems.org"\n\ngem "rails", "~> 8.1"\ngem "rspec-rails", "~> 8.0"\n),
    "config/application.rb" => "",
    ".rspec" => "--require spec_helper\n",
    "spec/spec_helper.rb" => SPEC_HELPER,
    "spec/rails_helper.rb" => RAILS_HELPER,
    "spec/models/post_spec.rb" => %(require "rails_helper"\n)
  }.freeze

  def setup_project(root, *options)
    out = StringIO.new
    err = StringIO.new
    code = SetupProject.run([*options, root], out: out, err: err)
    [code, out.string, err.string]
  end

  def test_rspec_project_gets_the_stack_without_minitest
    in_project(RSPEC) do |root|
      code, out, = setup_project(root)

      assert_equal 0, code
      gemfile = read(root, "Gemfile")
      refute_match(/gem "minitest"/, gemfile)
      %w[simplecov mutineer skunk rubycritic flog ostruct].each { |name| assert_match(/gem "#{name}"/, gemfile) }
      helper = read(root, "spec/spec_helper.rb")
      assert helper.start_with?(%(if ENV["COVERAGE"]\n  require "simplecov"\n  SimpleCov.start do\n    enable_coverage :branch\n    skip "/spec/"\n))
      assert helper.end_with?("end\n\n#{SPEC_HELPER}")
      assert_equal %(require "spec_helper"\nrequire "shop"\n), read(root, "spec/shop_spec.rb")
      assert_equal "--require spec_helper\n", read(root, ".rspec")
      mutineer = read(root, ".mutineer.yml")
      assert_equal 11, mutineer.scan(/^  - /).size
      assert mutineer.end_with?("threshold: 75\nframework: rspec\n")
      assert_includes read(root, "spec/tools/crap_spec.rb"), "RSpec.describe Crap do"
      refute File.exist?(File.join(root, "test"))
      refute File.exist?(File.join(root, "Rakefile"))
      assert_equal "coverage/\n.mutineer/\nspec/examples.txt\n", read(root, ".gitignore")
      workflow = read(root, ".github/workflows/ci.yml")
      assert_includes workflow, "run: COVERAGE=1 bundle exec rspec\n"
      assert_includes workflow, %(run: bundle exec bin/verify-change "$BASE_REF")
      assert_includes out, "\n  COVERAGE=1 bundle exec rspec\n"
    end
  end

  def test_rspec_project_running_twice_changes_nothing
    in_project(RSPEC) do |root|
      setup_project(root)
      snapshot = Dir.glob("**/*", File::FNM_DOTMATCH, base: root).select { |path| File.file?(File.join(root, path)) }.to_h { |path| [path, read(root, path)] }

      _code, out, = setup_project(root)

      snapshot.each { |path, content| assert_equal content, read(root, path), path }
      assert_empty out.lines.grep(/^(created|updated)/)
    end
  end

  def test_rspec_in_the_lockfile_creates_the_spec_helper_and_the_rspec_file
    files = { "Gemfile" => RSPEC["Gemfile"], "Gemfile.lock" => "GEM\n  specs:\n    rspec-core (3.13.6)\n\nDEPENDENCIES\n  rspec (~> 3.13)\n",
              "lib/shop.rb" => "class Shop; end\n" }
    in_project(files) do |root|
      code, = setup_project(root, "--no-ci")

      assert_equal 0, code
      helper = read(root, "spec/spec_helper.rb")
      assert helper.start_with?(%(if ENV["COVERAGE"]\n))
      assert_includes helper, "config.disable_monkey_patching!"
      assert_includes helper, %(config.example_status_persistence_file_path = "spec/examples.txt")
      assert_equal "--require spec_helper\n", read(root, ".rspec")
      assert_includes read(root, ".mutineer.yml"), "framework: rspec\n"
    end
  end

  def test_a_transitive_rspec_in_the_lockfile_keeps_minitest
    files = { "Gemfile" => %(source "https://rubygems.org"\n), "Gemfile.lock" => "GEM\n  specs:\n    rspec-core (3.13.6)\n\nDEPENDENCIES\n  minitest (~> 6.0)\n" }
    in_project(files) do |root|
      setup_project(root, "--no-ci")

      assert_match(/gem "minitest"/, read(root, "Gemfile"))
      assert File.exist?(File.join(root, "test/tools/crap_test.rb"))
      refute File.exist?(File.join(root, "spec"))
      refute_includes read(root, ".mutineer.yml"), "framework"
    end
  end

  def test_rails_rspec_app_gets_rails_coverage_in_the_spec_helper
    in_project(RAILS_RSPEC) do |root|
      code, _out, err = setup_project(root)

      assert_equal 0, code
      assert_empty err
      assert read(root, "spec/spec_helper.rb").start_with?(%(if ENV["COVERAGE"]\n  require "simplecov"\n  SimpleCov.start "rails" do))
      assert_equal RAILS_HELPER, read(root, "spec/rails_helper.rb")
      refute File.exist?(File.join(root, "test/test_helper.rb"))
      assert_includes read(root, ".github/workflows/ci.yml"), "run: bin/rails db:test:prepare && COVERAGE=1 bundle exec rspec\n"
    end
  end

  def test_rails_rspec_app_with_only_a_rails_helper_gets_coverage_there
    in_project(RAILS_RSPEC.except("spec/spec_helper.rb")) do |root|
      setup_project(root, "--no-ci")

      assert_equal read(root, "spec/rails_helper.rb"), "#{File.read(File.join(SKILL_ROOT, "assets/coverage/rails.rb"))}#{RAILS_HELPER}"
      refute File.exist?(File.join(root, "spec/spec_helper.rb"))
    end
  end

  def test_rails_rspec_app_without_helpers_asks_for_the_rspec_install
    in_project(RAILS_RSPEC.except("spec/spec_helper.rb", "spec/rails_helper.rb")) do |root|
      code, _out, err = setup_project(root, "--no-ci")

      assert_equal 0, code
      assert_includes err, "Run bin/rails generate rspec:install first"
    end
  end
end
