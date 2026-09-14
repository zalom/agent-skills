require "minitest/autorun"
require "yaml"
require_relative "support/project_fixtures"

class SkillComplianceTest < Minitest::Test
  ALLOWED_FRONTMATTER_KEYS = %w[name description license compatibility metadata allowed-tools].freeze
  SKILL_DIR_SENTENCE = "Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. " \
                       "Run a script by its full path, `SKILL_DIR/scripts/...`, where `SKILL_DIR` is that directory."
  SKILLS = { "ruby-testing" => TESTING_SKILL_ROOT, "ruby-quality-checking" => QUALITY_SKILL_ROOT }.freeze

  MOCK_BAN_PATTERN = /stub only at|only at (a |true )?boundar(y|ies)|(pass|prefer) real objects|couples the test|fixtures over factories/i

  def test_frontmatter_is_within_the_allowed_keys_and_matches_the_folder
    SKILLS.each do |name, root|
      frontmatter = read_frontmatter(File.join(root, "SKILL.md"))
      assert_empty frontmatter.keys - ALLOWED_FRONTMATTER_KEYS, "#{name}: disallowed frontmatter keys"
      assert_equal name, frontmatter["name"]
    end
  end

  def test_descriptions_are_under_1024_characters
    SKILLS.each do |name, root|
      frontmatter = read_frontmatter(File.join(root, "SKILL.md"))
      assert_operator frontmatter["description"].to_s.length, :<, 1024, "#{name}: description too long"
    end
  end

  def test_skill_md_files_are_under_300_lines
    SKILLS.each do |name, root|
      lines = File.readlines(File.join(root, "SKILL.md")).size
      assert_operator lines, :<, 300, "#{name}: SKILL.md too long"
    end
  end

  def test_the_skill_dir_sentence_appears_word_for_word
    SKILLS.each do |name, root|
      content = File.read(File.join(root, "SKILL.md"))
      assert_includes content, SKILL_DIR_SENTENCE, "#{name}: missing the SKILL_DIR sentence"
    end
  end

  def test_no_claude_only_frontmatter_or_skill_dir_variable
    SKILLS.each_value do |root|
      markdown_files(root).each do |file|
        content = File.read(file)
        refute_includes content, "${CLAUDE_SKILL_DIR}", file
        refute_match(/^user-invocable:/, content, file)
      end
    end
  end

  def test_ruby_verifying_is_named_only_in_the_changelog
    SKILLS.each_value do |root|
      markdown_files(root).each do |file|
        refute_includes File.read(file), "ruby-verifying", file
      end
    end
  end

  def test_ruby_testing_never_bans_collaboration_mocks
    markdown_files(TESTING_SKILL_ROOT).each do |file|
      content = File.read(file)
      next unless content.match?(MOCK_BAN_PATTERN)

      # "Integration tests run real objects" is the one allowed exception.
      offending = content.each_line.select { |line| line.match?(MOCK_BAN_PATTERN) && !line.include?("Integration tests run real objects") }
      assert_empty offending, "#{file}: #{offending.join}"
    end
  end

  def test_every_sibling_path_in_a_skill_resolves_inside_that_skill
    SKILLS.each do |name, root|
      files = [File.join(root, "SKILL.md")] + markdown_files(root)
      files.uniq.each do |file|
        File.read(file).scan(/`((?:references|scripts|assets)\/[^`]+)`/).each do |(relative)|
          path = relative.split(/[\s(]/).first
          assert File.exist?(File.join(root, path)), "#{name} #{file}: #{path} does not resolve inside #{name}"
        end
      end
    end
  end

  private

  def read_frontmatter(skill_md_path)
    content = File.read(skill_md_path)
    _blank, frontmatter, = content.split(/^---\s*$/, 3)
    YAML.safe_load(frontmatter)
  end

  def markdown_files(root)
    Dir.glob(File.join(root, "references/**/*.md"))
  end
end
