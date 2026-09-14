# Reads a project's test and quality tooling from its files. Runs no commands.
# Kept byte-identical between ruby-testing/scripts/project_profile.rb and
# ruby-quality-checking/scripts/project_profile.rb; test/skills_sync_test.rb enforces it.
class ProjectProfile
  RSPEC_DEPENDENCY = /^  rspec(-core|-rails)?(\s|!|$)/
  MINITEST_MOCK_DEPENDENCY = /^  minitest-mock(\s|!|$)/
  MOCHA_DEPENDENCY = /^  mocha(\s|!|$)/
  FACTORY_BOT_DEPENDENCY = /^  factory_bot(-rails)?(\s|!|$)/
  MUTATION_TOOLS = { mutineer: "mutineer", mutant: "mutant", evilution: "evilution", henitai: "henitai" }.freeze
  MINITEST_SIX = Gem::Version.new("6.0")
  SIMPLECOV_PATCH_MINIMUM = Gem::Version.new("1.3")

  Missing = Struct.new(:goal, :why, :tool, keyword_init: true)

  def initialize(root)
    @root = root
  end

  def ruby_version
    version_file = read(".ruby-version")&.strip&.delete_prefix("ruby-")
    tool_versions = read(".tool-versions")&.[](/^ruby\s+(\S+)/, 1)
    mise = read("mise.toml")&.[](/^ruby\s*=\s*"([^"]+)"/, 1)
    gemfile = gemfile_text[/^ruby\s+["']([^"']+)["']/, 1]
    [version_file, tool_versions, mise, gemfile].compact.reject(&:empty?).first
  end

  def rails?
    exist?("config/application.rb")
  end

  def gemfile?
    File.file?(path("Gemfile"))
  end

  def frameworks
    found = []
    found << :minitest if minitest_detected?
    found << :rspec if rspec_detected?
    found
  end

  def primary_framework
    frameworks.include?(:rspec) ? :rspec : :minitest
  end

  def minitest_version
    gem_version("minitest")
  end

  def simplecov_version
    gem_version("simplecov")
  end

  def test_data
    found = []
    found << :fixtures unless Dir.glob(File.join(@root, "{test,spec}/fixtures/**/*.yml")).empty?
    found << :factories if dependencies_section.match?(FACTORY_BOT_DEPENDENCY) || exist?("test/factories") || exist?("spec/factories")
    found
  end

  def mocking
    found = []
    found << :minitest_mock if dependencies_section.match?(MINITEST_MOCK_DEPENDENCY) || minitest_mock_builtin?
    found << :mocha if dependencies_section.match?(MOCHA_DEPENDENCY)
    found << :rspec_mocks if frameworks.include?(:rspec)
    found.uniq
  end

  def coverage
    declared?("simplecov") ? :simplecov : nil
  end

  def mutation_tool
    MUTATION_TOOLS.find { |_symbol, gem_name| declared?(gem_name) }&.first
  end

  def crap_configured?
    exist?("bin/crap")
  end

  def style_guide
    return :ambiguous if ambiguous_style_guide?
    return :omakase if omakase?
    return :standard if standard?
    return :rubocop if rubocop?

    nil
  end

  def ci
    found = []
    found << :github unless Dir.glob(File.join(@root, ".github/workflows/*.{yml,yaml}")).empty?
    found << :gitlab if exist?(".gitlab-ci.yml")
    found << :circleci if exist?(".circleci/config.yml")
    found
  end

  def database_adapter
    content = read("config/database.yml")
    return nil unless content

    content[/^\s*adapter:\s*(\S+)/, 1]
  end

  def compose_file?
    exist?("compose.yaml") || exist?("compose.yml") || exist?("docker-compose.yml")
  end

  def missing
    items = []
    items << Missing.new(goal: "test framework", why: "no Minitest or RSpec tests were found", tool: "minitest") if frameworks.empty?
    items << Missing.new(goal: "patch coverage", why: coverage_gap_reason, tool: "simplecov") if coverage_gap?
    items << Missing.new(goal: "mutation testing", why: "tests are not proven to catch behavior changes without it", tool: "mutineer") unless mutation_tool
    items << Missing.new(goal: "CRAP scores", why: "complex, undertested methods are not ranked without it", tool: "bin/crap") unless crap_configured?
    items << Missing.new(goal: "a style guide", why: "the project has no lint step", tool: "rubocop-rails-omakase, standard, or rubocop") if style_guide.nil?
    items << Missing.new(goal: "minitest-mock", why: "Minitest 6 moved Minitest::Mock and stub out of core", tool: "minitest-mock") if minitest_mock_gap?
    items << Missing.new(goal: "CI", why: "the full suite has nowhere to run on every push", tool: "GitHub Actions, GitLab CI, or CircleCI") if ci.empty?
    items
  end

  def to_h
    {
      "ruby_version" => ruby_version,
      "rails" => rails?,
      "frameworks" => frameworks.map(&:to_s),
      "primary_framework" => primary_framework.to_s,
      "minitest_version" => minitest_version,
      "simplecov_version" => simplecov_version,
      "test_data" => test_data.map(&:to_s),
      "mocking" => mocking.map(&:to_s),
      "coverage" => coverage&.to_s,
      "mutation_tool" => mutation_tool&.to_s,
      "crap_configured" => crap_configured?,
      "style_guide" => style_guide&.to_s,
      "ci" => ci.map(&:to_s),
      "missing" => missing.map { |item| { "goal" => item.goal, "why" => item.why, "tool" => item.tool } }
    }
  end

  private

  def minitest_detected?
    exist?("test/test_helper.rb") || !Dir.glob(File.join(@root, "test/**/*_test.rb")).empty?
  end

  def rspec_detected?
    (exist?("spec") && (exist?(".rspec") || exist?("spec/spec_helper.rb") || exist?("spec/rails_helper.rb"))) ||
      dependencies_section.match?(RSPEC_DEPENDENCY)
  end

  def minitest_mock_builtin?
    version = minitest_version
    version && Gem::Version.new(version) < MINITEST_SIX
  end

  def minitest_mock_gap?
    return false unless frameworks.include?(:minitest) && minitest_version

    Gem::Version.new(minitest_version) >= MINITEST_SIX && !mocking.include?(:minitest_mock)
  end

  def coverage_gap?
    return true unless coverage

    version = simplecov_version
    version && Gem::Version.new(version) < SIMPLECOV_PATCH_MINIMUM
  end

  def coverage_gap_reason
    return "changed lines are not proven covered without it" unless coverage

    "SimpleCov #{simplecov_version} is below 1.3, so simplecov patch does not exist"
  end

  def ambiguous_style_guide?
    exist?(".standard.yml") && exist?(".rubocop.yml") && !rubocop_config_uses_standard?
  end

  def omakase?
    declared?("rubocop-rails-omakase") || rubocop_config.match?(/inherit_gem:\s*\n?\s*rubocop-rails-omakase:/m)
  end

  def standard?
    declared?("standard") || exist?(".standard.yml") || rubocop_config_uses_standard?
  end

  def rubocop?
    declared?("rubocop") || exist?(".rubocop.yml")
  end

  def rubocop_config_uses_standard?
    config = rubocop_config
    return false if config.empty?

    config.match?(/inherit_gem:\s*\{?\s*standard:/m) ||
      config.match?(/^(plugins|require):\s*\n(\s*-\s*standard\s*\n)+/m) ||
      config.match?(/^(plugins|require):\s*\[[^\]]*\bstandard\b[^\]]*\]/m)
  end

  def rubocop_config
    read(".rubocop.yml") || ""
  end

  def declared?(name)
    dependencies_section.match?(dependency_pattern(name)) ||
      gemfile_text.match?(/^\s*gem\s+["']#{Regexp.escape(name)}["']/) ||
      gemspec_text.match?(/add_development_dependency\s+["']#{Regexp.escape(name)}["']/)
  end

  def dependency_pattern(name)
    /^  #{Regexp.escape(name)}(\s|!|\z)/
  end

  def dependencies_section
    return @dependencies_section if defined?(@dependencies_section)

    lockfile = read("Gemfile.lock")
    unless lockfile
      return @dependencies_section = ""
    end

    lines = lockfile.lines
    start = lines.index { |line| line.strip == "DEPENDENCIES" }
    unless start
      return @dependencies_section = ""
    end

    section = []
    lines[(start + 1)..].each do |line|
      break if line.strip.empty?

      section << line
    end
    @dependencies_section = section.join
  end

  def gem_version(name)
    lockfile = read("Gemfile.lock")
    return nil unless lockfile

    match = lockfile.match(/^    #{Regexp.escape(name)} \(([\d.]+)\)/)
    match && match[1]
  end

  def gemfile_text
    @gemfile_text ||= read("Gemfile").to_s
  end

  def gemspec_text
    @gemspec_text ||= Dir.glob(File.join(@root, "*.gemspec")).map { |file| File.read(file) }.join("\n")
  end

  def read(relative)
    File.file?(path(relative)) ? File.read(path(relative)) : nil
  end

  def exist?(relative)
    File.exist?(path(relative))
  end

  def path(relative)
    File.join(@root, relative)
  end
end
