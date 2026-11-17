require "minitest/autorun"
require "yaml"
require_relative "support/project_fixtures"

class SkillComplianceTest < Minitest::Test
  ALLOWED_FRONTMATTER_KEYS = %w[name description license compatibility metadata allowed-tools].freeze
  SKILL_DIR_SENTENCE = "Paths in this file start at the skill directory, the directory that holds this `SKILL.md`. " \
                       "`SKILL_DIR` is the absolute path of that directory; find it before running a script. Run a " \
                       "script by its full path, `SKILL_DIR/scripts/...`, and read its real output. Never predict " \
                       "or invent what a script prints."
  SKILLS = {
    "ruby-programming" => PROGRAMMING_SKILL_ROOT,
    "simple-architecture-designing" => ARCHITECTURE_SKILL_ROOT,
    "database-designing" => DATABASE_SKILL_ROOT,
    "ruby-testing" => TESTING_SKILL_ROOT,
    "ruby-quality-checking" => QUALITY_SKILL_ROOT,
    "c4-model-diagramming" => C4_SKILL_ROOT,
    "report-writing" => REPORT_SKILL_ROOT
  }.freeze
  QUALITY_STACK_NAMES = %w[setup-project bin/verify-change .mutineer.yml bin/crap].freeze

  MOCK_BAN_PATTERN = /stub only at|at (a |true )?boundar(y|ies)|(pass|prefer) real objects|couples the test|fixtures over factories/i
  # Lines that match MOCK_BAN_PATTERN by coincidence but read as advice, not a boundary-only or
  # fixtures-over-factories rule (review finding 5).
  MOCK_BAN_ALLOWED = [
    "Integration tests run real objects",
    "Use a double at a boundary",
    "Stub the clock, randomness, the network, and external IO"
  ].freeze

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

      offending = content.each_line.select { |line| line.match?(MOCK_BAN_PATTERN) && MOCK_BAN_ALLOWED.none? { |allowed| line.include?(allowed) } }
      assert_empty offending, "#{file}: #{offending.join}"
    end
  end

  def test_ruby_testing_has_no_route_to_the_quality_stack
    content = File.read(File.join(TESTING_SKILL_ROOT, "SKILL.md"))
    QUALITY_STACK_NAMES.each { |name| refute_includes content, name, "ruby-testing/SKILL.md names #{name}" }
  end

  def test_every_sibling_path_in_a_skill_resolves_inside_that_skill
    SKILLS.each do |name, root|
      markdown_files(root).each do |file|
        content = File.read(file)
        content.scan(/`((?:references|scripts|assets)\/[^`]+)`/).each do |(relative)|
          path = relative.split(/[\s(]/).first
          assert File.exist?(File.join(root, path)), "#{name} #{file}: #{path} does not resolve inside #{name}"
        end
        content.scan(/`([\w-]+\.md)`/).each do |(bare)|
          next if bare == "SKILL.md"

          assert File.exist?(File.join(root, "references", bare)), "#{name} #{file}: #{bare} does not resolve inside #{name}/references"
        end
      end
    end
  end

  def test_one_ruby_skill_holds_both_writing_and_designing
    marketplace = File.read(File.expand_path("../.claude-plugin/marketplace.json", __dir__))
    %w[ruby-writing ruby-designing].each do |retired|
      refute File.exist?(File.expand_path("../#{retired}", __dir__)), retired
      refute_includes marketplace, %Q{"#{retired}"}, retired
    end
  end

  def test_the_base_skill_opens_with_how_to_approach_the_work
    content = File.read(File.join(ARCHITECTURE_SKILL_ROOT, "SKILL.md"))
    assert_operator content.index("## How to approach the work"), :<, content.index("## Rules")
  end

  def test_the_specific_skills_start_from_the_base_skill
    [PROGRAMMING_SKILL_ROOT, DATABASE_SKILL_ROOT].each do |root|
      assert_includes File.read(File.join(root, "SKILL.md")), "simple-architecture-designing", root
    end
  end

  def test_every_proof_script_is_named_by_a_reference
    references = markdown_files(PROGRAMMING_SKILL_ROOT).map { |file| File.read(file) }.join
    Dir.children(File.join(PROGRAMMING_SKILL_ROOT, "scripts")).each do |script|
      assert_includes references, "scripts/#{script}", script
    end
  end

  def test_the_base_skills_name_no_database_engine
    [ARCHITECTURE_SKILL_ROOT, DATABASE_SKILL_ROOT].each do |root|
      markdown_files(root).each { |file| refute_match(/sqlite|postgres|mysql|mongo|redis|dynamo/i, File.read(file), file) }
    end
  end

  def test_the_general_skills_name_no_programming_language
    [ARCHITECTURE_SKILL_ROOT, DATABASE_SKILL_ROOT].each do |root|
      markdown_files(root).each { |file| refute_match(/\b(ruby|rails|python|javascript|typescript|java|golang|rust)\b/i, File.read(file), file) }
    end
  end

  def test_the_design_skills_route_data_work_to_database_designing
    [PROGRAMMING_SKILL_ROOT, ARCHITECTURE_SKILL_ROOT].each do |root|
      assert_includes File.read(File.join(root, "SKILL.md")), "database-designing", root
    end
  end

  private

  def read_frontmatter(skill_md_path)
    content = File.read(skill_md_path)
    _blank, frontmatter, = content.split(/^---\s*$/, 3)
    YAML.safe_load(frontmatter)
  end

  def markdown_files(root)
    Dir.glob(File.join(root, "{SKILL.md,references/**/*.md}"))
  end
end
