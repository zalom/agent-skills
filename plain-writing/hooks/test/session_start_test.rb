# frozen_string_literal: true

# Hermetic tests for the plain-writing SessionStart hook, reached through run-hook.sh.
# No eval, no global or environment injection: the skill root is passed as ARGV.

require "minitest/autorun"
require "open3"
require "json"
require "tmpdir"
require "fileutils"

class SessionStartHookTest < Minitest::Test
  SHIM = File.expand_path("../run-hook.sh", __dir__)
  HOOK_NAME = "session-start"
  PERSONAL_OVERRIDES = File.expand_path("~/.claude/plain-writing-overrides.md")
  STDIN_PAYLOAD = JSON.generate(
    "session_id" => "test-session",
    "hook_event_name" => "SessionStart",
    "source" => "startup",
    "cwd" => Dir.pwd
  )

  def run_hook(*args)
    out, _err, status = Open3.capture3(SHIM, HOOK_NAME, *args, stdin_data: STDIN_PAYLOAD)
    [out, status]
  end

  def context_for(*args)
    out, status = run_hook(*args)
    assert_equal 0, status.exitstatus
    payload = JSON.parse(out)
    assert_nil payload["systemMessage"], "success must stay silent on screen"
    payload["hookSpecificOutput"]["additionalContext"]
  end

  def write_skill(dir, skill:, highlights:, overrides:)
    FileUtils.mkdir_p(File.join(dir, "references", "google"))
    File.write(File.join(dir, "SKILL.md"), skill)
    File.write(File.join(dir, "references", "google", "highlights.md"), highlights)
    File.write(File.join(dir, "references", "overrides.md"), overrides)
  end

  def test_injects_the_activation_set
    Dir.mktmpdir do |dir|
      write_skill(dir, skill: "# Writing style\n", highlights: "# Highlights\n", overrides: "Use a hyphen.\n")

      context = context_for(dir)
      assert_includes context, "## File: SKILL.md"
      assert_includes context, "## File: references/google/highlights.md"
      assert_includes context, "## File: references/overrides.md"
      refute_includes context, "skipped for size"
    end
  end

  def test_drops_the_highlights_before_the_skill_body
    Dir.mktmpdir do |dir|
      write_skill(dir, skill: "s" * 8_000, highlights: "h" * 10_000, overrides: "Use a hyphen.\n")

      context = context_for(dir)
      assert_operator context.length, :<, 16_000
      assert_includes context, "## File: references/overrides.md"
      assert_includes context, "## File: SKILL.md"
      refute_includes context, "## File: references/google/highlights.md"
      assert_includes context, "skipped for size"
    end
  end

  def test_keeps_the_overrides_when_the_skill_body_alone_is_too_big
    Dir.mktmpdir do |dir|
      write_skill(dir, skill: "s" * 15_900, highlights: "# Highlights\n", overrides: "Use a hyphen.\n")

      context = context_for(dir)
      assert_operator context.length, :<, 16_000
      assert_includes context, "## File: references/overrides.md"
      assert_includes context, "Use a hyphen."
      refute_includes context, "## File: SKILL.md"
      assert_includes context, "skipped for size"
    end
  end

  def test_strips_the_yaml_frontmatter_from_the_skill_body
    Dir.mktmpdir do |dir|
      write_skill(
        dir,
        skill: "---\nname: plain-writing\ndescription: Governs style.\n---\n\n# Writing style\n",
        highlights: "# Highlights\n",
        overrides: "Use a hyphen.\n"
      )

      context = context_for(dir)
      assert_includes context, "## File: SKILL.md\n\n# Writing style"
      refute_includes context, "name: plain-writing"
    end
  end

  def test_injects_the_whole_installed_activation_set
    root = Dir.glob(File.expand_path("~/.claude/plugins/cache/zalom-skills/plain-writing/*"))
              .select { |path| File.file?(File.join(path, "SKILL.md")) }
              .max_by { |path| Gem::Version.new(File.basename(path)) rescue Gem::Version.new("0") }
    skip "plain-writing plugin not installed" unless root

    context = context_for(root)
    refute_includes context, "skipped for size"
    assert_includes context, "## File: SKILL.md"
    assert_includes context, "## File: references/google/highlights.md"
    assert_includes context, "## File: references/overrides.md"
    assert_includes context, "## Routing table"
  end

  def test_injects_the_personal_overrides_from_outside_the_skill
    skip "no personal overrides file" unless File.file?(PERSONAL_OVERRIDES)

    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "SKILL.md"), "# Writing style\n")

      context = context_for(dir)
      assert_includes context, "## File: references/overrides.md"
      assert_includes context, File.read(PERSONAL_OVERRIDES, encoding: "UTF-8").strip
    end
  end

  def test_reads_non_ascii_content_as_utf8
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "SKILL.md"), "# Writing style\n\nCafé test.\n")

      out, status = run_hook(dir)
      assert_equal 0, status.exitstatus
      payload = JSON.parse(out)
      assert payload.key?("hookSpecificOutput")
    end
  end

  def test_fails_open_when_the_root_is_missing
    Dir.mktmpdir do |dir|
      out, status = run_hook(File.join(dir, "no-such-skill"))
      assert_equal 0, status.exitstatus
      payload = JSON.parse(out)
      assert_includes payload["systemMessage"], "not found"
      refute payload.key?("hookSpecificOutput")
    end
  end

  def test_skips_the_references_when_the_set_is_too_big
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "SKILL.md"), "# Writing style\n\nA small skill body.\n")
      FileUtils.mkdir_p(File.join(dir, "references", "google"))
      File.write(File.join(dir, "references", "google", "highlights.md"), "x" * 18_000)

      context = context_for(dir)
      assert_operator context.length, :<, 16_000
      assert_includes context, "skipped for size"
      assert_includes context, "## File: SKILL.md"
      refute_includes context, "## File: references/google/highlights.md"
    end
  end
end
