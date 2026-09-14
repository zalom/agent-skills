require_relative "test_helper"

class ProjectProfileTest < Minitest::Test
  include ProjectFixtures

  def profile(root)
    ProjectProfile.new(root)
  end

  # Framework detection

  def test_rails_app_with_rspec_rails_and_transitive_minitest_reads_as_rspec
    files = { "config/application.rb" => "", ".rspec" => "", "spec/spec_helper.rb" => "",
              "Gemfile.lock" => "GEM\n  specs:\n    minitest (6.0.6)\n\nDEPENDENCIES\n  rspec-rails (~> 8.0)\n" }
    in_project(files) do |root|
      assert_equal [:rspec], profile(root).frameworks
    end
  end

  def test_test_helper_with_no_lockfile_reads_as_minitest
    in_project("test/test_helper.rb" => "") do |root|
      assert_equal [:minitest], profile(root).frameworks
    end
  end

  def test_both_test_and_spec_are_reported
    files = { "test/test_helper.rb" => "", ".rspec" => "", "spec/spec_helper.rb" => "" }
    in_project(files) do |root|
      assert_equal %i[minitest rspec], profile(root).frameworks.sort
    end
  end

  def test_plain_project_with_no_tests_reads_as_empty
    in_project("lib/shop.rb" => "class Shop; end\n") do |root|
      assert_empty profile(root).frameworks
    end
  end

  def test_spec_helper_with_no_rspec_file_and_no_lockfile_reads_as_rspec
    in_project("spec/spec_helper.rb" => "") do |root|
      assert_equal [:rspec], profile(root).frameworks
    end
  end

  def test_rspec_rails_with_leftover_test_helper_reports_both_and_picks_rspec
    files = { "config/application.rb" => "", "test/test_helper.rb" => "", ".rspec" => "", "spec/spec_helper.rb" => "" }
    in_project(files) do |root|
      p = profile(root)
      assert_equal %i[minitest rspec], p.frameworks.sort
      assert_equal :rspec, p.primary_framework
    end
  end

  def test_gemfile_rspec_and_gem_list_minitest_are_not_evidence
    files = { "Gemfile" => %(gem "rspec"\ngem "minitest"\n) }
    in_project(files) do |root|
      assert_empty profile(root).frameworks
    end
  end

  # Lockfile parsing

  def test_checksums_transitive_rspec_core_does_not_trigger_rspec
    lockfile = "GEM\n  specs:\n    minitest (6.0.6)\n\nDEPENDENCIES\n  minitest (~> 6.0)\n\n" \
               "CHECKSUMS\n  rspec-core (3.13.6) sha256=aaa\n  minitest (6.0.6) sha256=bbb\n"
    in_project("Gemfile.lock" => lockfile, "test/test_helper.rb" => "") do |root|
      assert_equal [:minitest], profile(root).frameworks
    end
  end

  def test_dependencies_as_the_last_section_with_no_trailing_blank_line_still_reads
    lockfile = "GEM\n  specs:\n    rspec-core (3.13.6)\n\nDEPENDENCIES\n  rspec (~> 3.13)"
    in_project("Gemfile.lock" => lockfile) do |root|
      assert_equal [:rspec], profile(root).frameworks
    end
  end

  def test_minitest_version_reads_only_the_four_space_specs_line
    lockfile = "GEM\n  specs:\n    activesupport (8.1.3)\n      minitest (>= 5.1)\n    minitest (6.0.6)\n\n" \
               "DEPENDENCIES\n  minitest (~> 6.0)\n\nCHECKSUMS\n  minitest (6.0.6) sha256=ccc\n"
    in_project("Gemfile.lock" => lockfile) do |root|
      assert_equal "6.0.6", profile(root).minitest_version
    end
  end

  # Test data

  def test_fixtures_and_factories_are_both_reported
    files = { "test/fixtures/users.yml" => "", "test/factories/users.rb" => "" }
    in_project(files) do |root|
      assert_equal %i[factories fixtures], profile(root).test_data.sort
    end
  end

  # Tool declared beyond the lockfile

  def test_simplecov_declared_only_in_the_gemfile_is_read_without_a_lockfile
    in_project("Gemfile" => %(gem "simplecov", "~> 1.3"\n)) do |root|
      assert_equal :simplecov, profile(root).coverage
    end
  end

  def test_mutineer_declared_in_a_gemspec_is_read
    gemspec = %(Gem::Specification.new do |s|\n  s.add_development_dependency "mutineer"\nend\n)
    in_project("demo.gemspec" => gemspec) do |root|
      assert_equal :mutineer, profile(root).mutation_tool
    end
  end

  # Mocking

  def test_rspec_project_with_only_rspec_rails_reports_rspec_mocks
    files = { ".rspec" => "", "spec/spec_helper.rb" => "", "Gemfile.lock" => "DEPENDENCIES\n  rspec-rails (~> 8.0)\n" }
    in_project(files) do |root|
      assert_includes profile(root).mocking, :rspec_mocks
    end
  end

  # Missing list

  def test_minitest_five_without_minitest_mock_has_no_gap
    lockfile = "GEM\n  specs:\n    minitest (5.25.4)\n\nDEPENDENCIES\n  minitest (~> 5.25)\n"
    in_project("Gemfile.lock" => lockfile, "test/test_helper.rb" => "") do |root|
      refute profile(root).missing.any? { |item| item.tool == "minitest-mock" }
    end
  end

  def test_simplecov_below_1_3_is_a_gap_naming_the_version
    lockfile = "GEM\n  specs:\n    simplecov (1.2.0)\n\nDEPENDENCIES\n  simplecov (~> 1.2)\n"
    in_project("Gemfile.lock" => lockfile) do |root|
      item = profile(root).missing.find { |candidate| candidate.tool == "simplecov" }
      refute_nil item
      assert_includes item.why, "1.3"
    end
  end

  def test_a_fully_set_up_project_has_no_gaps
    lockfile = "GEM\n  specs:\n    minitest (6.0.6)\n    simplecov (1.3.0)\n\n" \
               "DEPENDENCIES\n  minitest (~> 6.0)\n  minitest-mock (~> 5.27)\n  simplecov (~> 1.3)\n  mutineer (~> 1.0)\n  rubocop (~> 1.0)\n"
    files = {
      "Gemfile.lock" => lockfile,
      "test/test_helper.rb" => "",
      "bin/crap" => "",
      ".rubocop.yml" => "",
      ".github/workflows/ci.yml" => ""
    }
    in_project(files) do |root|
      assert_empty profile(root).missing
    end
  end

  # Linters

  def test_inherit_gem_omakase_reads_as_omakase
    config = "inherit_gem:\n  rubocop-rails-omakase: rubocop.yml\n"
    in_project(".rubocop.yml" => config) do |root|
      assert_equal :omakase, profile(root).style_guide
    end
  end

  def test_plugins_block_list_standard_reads_as_standard
    config = "plugins:\n  - standard\n"
    in_project(".rubocop.yml" => config) do |root|
      assert_equal :standard, profile(root).style_guide
    end
  end

  def test_inherit_gem_flow_form_standard_reads_as_standard
    config = "require: standard\ninherit_gem: { standard: config/base.yml }\n"
    lockfile = "DEPENDENCIES\n  rubocop (~> 1.88)\n"
    in_project(".rubocop.yml" => config, "Gemfile.lock" => lockfile) do |root|
      assert_equal :standard, profile(root).style_guide
    end
  end

  def test_require_flow_list_standard_reads_as_standard
    config = "require: [standard]\n"
    lockfile = "DEPENDENCIES\n  rubocop (~> 1.88)\n"
    in_project(".rubocop.yml" => config, "Gemfile.lock" => lockfile) do |root|
      assert_equal :standard, profile(root).style_guide
    end
  end

  def test_standard_yml_beside_an_unrelated_rubocop_yml_is_ambiguous
    files = { ".standard.yml" => "", ".rubocop.yml" => "require:\n  - rubocop-rails\n" }
    in_project(files) do |root|
      assert_equal :ambiguous, profile(root).style_guide
    end
  end

  def test_rubocop_and_omakase_both_declared_reads_as_omakase
    lockfile = "DEPENDENCIES\n  rubocop (~> 1.0)\n  rubocop-rails-omakase\n"
    in_project("Gemfile.lock" => lockfile) do |root|
      assert_equal :omakase, profile(root).style_guide
    end
  end

  # Mutineer configured without the gem

  def test_mutineer_yml_without_the_gem_is_not_reported_as_installed
    in_project(".mutineer.yml" => "threshold: 75\n") do |root|
      assert_nil profile(root).mutation_tool
    end
  end

  # CI

  def test_github_workflow_with_yaml_extension_is_detected
    in_project(".github/workflows/ci.yaml" => "") do |root|
      assert_includes profile(root).ci, :github
    end
  end
end
