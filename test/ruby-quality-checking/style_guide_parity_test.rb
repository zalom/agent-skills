require_relative "test_helper"

# ProjectProfile#style_guide and VerifyChange's lint-or-skip decision are deliberately
# different trees (review finding 7): the lint *command* is chosen from the config file
# present, not from the abstract style_guide symbol, because a .rubocop.yml that wires in
# Standard still needs rubocop, not standardrb, to read it. So this is a looser parity test:
# for each fixture, it checks that ProjectProfile#style_guide and verify-change's actual lint
# command agree on the documented mapping (including the one documented exception), not that
# they are always literally equal.
class StyleGuideParityTest < Minitest::Test
  include ProjectFixtures

  Status = Struct.new(:success) do
    def success? = success
  end

  # profile: what ProjectProfile#style_guide reads (nil for "no gap reported").
  # lint: the branch verify-change's lint decision actually takes.
  # These differ only for a .rubocop.yml that wires in Standard: the profile reports the
  # underlying style guide (:standard), but the command must still be rubocop, because
  # rubocop is what reads that config file (review finding 7).
  ROWS = [
    { name: "no style guide", files: {}, profile: nil, lint: :skip },
    { name: "plain rubocop", files: { ".rubocop.yml" => "", "Gemfile.lock" => "DEPENDENCIES\n  rubocop (~> 1.0)\n" }, profile: :rubocop, lint: :rubocop },
    { name: "standard alone", files: { ".standard.yml" => "", "Gemfile.lock" => "DEPENDENCIES\n  standard (~> 1.0)\n" }, profile: :standard, lint: :standard },
    { name: "omakase", files: { ".rubocop.yml" => "inherit_gem:\n  rubocop-rails-omakase: rubocop.yml\n",
                                 "Gemfile.lock" => "DEPENDENCIES\n  rubocop-rails-omakase\n" }, profile: :omakase, lint: :rubocop },
    { name: "standard via plugins block list in .rubocop.yml", files: { ".rubocop.yml" => "plugins:\n  - standard\n",
                                                                          "Gemfile.lock" => "DEPENDENCIES\n  standard (~> 1.0)\n" }, profile: :standard, lint: :rubocop },
    { name: "standard via inherit_gem flow form in .rubocop.yml", files: { ".rubocop.yml" => "require: standard\ninherit_gem: { standard: config/base.yml }\n",
                                                                             "Gemfile.lock" => "DEPENDENCIES\n  rubocop (~> 1.88)\n  standard (~> 1.56)\n" }, profile: :standard, lint: :rubocop },
    { name: "standard via inherit_gem flow form beside a standard.yml", files: { ".rubocop.yml" => "require: standard\ninherit_gem: { standard: config/base.yml }\n",
                                                                                    ".standard.yml" => "",
                                                                                    "Gemfile.lock" => "DEPENDENCIES\n  rubocop (~> 1.88)\n  standard (~> 1.56)\n" }, profile: :standard, lint: :rubocop },
    { name: "ambiguous", files: { ".standard.yml" => "", ".rubocop.yml" => "require:\n  - rubocop-rails\n" }, profile: :ambiguous, lint: :skip }
  ].freeze

  # Both scripts detect Standard's rubocop.yml wiring from the config file text alone (review
  # finding 3): this asserts their two implementations agree, not only that documented fixtures
  # happen to agree.
  CONFIGS = [
    "",
    "AllCops:\n  NewCops: enable\n",
    "inherit_gem:\n  standard: config/base.yml\n",
    "inherit_gem: { standard: config/base.yml }\n",
    "require: standard\ninherit_gem: { standard: config/base.yml }\n",
    "plugins:\n  - standard\n",
    "plugins:\n  - rubocop-performance\n  - standard\n",
    "require: [standard]\n"
  ].freeze

  def git_stub(changed:)
    lambda do |*args|
      case args.first
      when "merge-base" then ["abc123\n", Status.new(true)]
      when "diff" then [changed.join("\n"), Status.new(true)]
      when "ls-files" then ["", Status.new(true)]
      end
    end
  end

  def actual_lint_branch(root, lint_files)
    runner = ->(_env, _command) { true }
    change = VerifyChange.new(["main"], root: root, out: StringIO.new, err: StringIO.new, git: git_stub(changed: lint_files), run: runner)
    decision = change.send(:lint_decision, lint_files)
    return :skip unless decision.step

    decision.step.command.first(3) == %w[bundle exec rubocop] ? :rubocop : :standard
  end

  ROWS.each do |row|
    define_method("test_#{row[:name].downcase.gsub(/[^a-z0-9]+/, "_")}") do
      files = row[:files].merge("lib/refund.rb" => "", "test/refund_test.rb" => "")
      in_project(files) do |root|
        style_guide = ProjectProfile.new(root).style_guide
        row[:profile].nil? ? assert_nil(style_guide, row[:name]) : assert_equal(row[:profile], style_guide, "#{row[:name]}: ProjectProfile#style_guide")
        assert_equal row[:lint], actual_lint_branch(root, ["lib/refund.rb"]), "#{row[:name]}: verify-change's lint branch"
      end
    end
  end

  def test_the_standard_wiring_regex_agrees_across_both_scripts
    CONFIGS.each do |config|
      in_project(".rubocop.yml" => config) do |root|
        profile_result = ProjectProfile.new(root).send(:rubocop_config_uses_standard?)
        change = VerifyChange.new(["main"], root: root, out: StringIO.new, err: StringIO.new, git: git_stub(changed: []), run: ->(*) { true })
        verify_result = change.send(:rubocop_config_uses_standard?)

        assert_equal profile_result, verify_result, config
      end
    end
  end
end
