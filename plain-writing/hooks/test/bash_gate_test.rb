# frozen_string_literal: true

# Tests for bash-gate.sh, the PostToolUse hook that applies the guide to prose written
# through Bash. The shipped gate is registered on Write and Edit, so a document created with
# a heredoc, sed -i, tee or a script never reaches it. This hook closes that path.
#
# Every failure mode must exit 0 and print nothing, so a broken install never disturbs a
# session, and a command that touches no prose must stay silent.

require "minitest/autorun"
require "open3"
require "tmpdir"
require "json"

class BashGateTest < Minitest::Test
  HOOK = File.expand_path("../bash-gate.sh", __dir__)
  SHIM = File.expand_path("../run-hook.sh", __dir__)

  WITH_VIOLATIONS = "# Reviewing the results\n\nWe shipped to eleven regions.\n"

  def payload(command, dir, extra = {})
    JSON.generate({
      tool_name: "Bash",
      session_id: "test-#{rand(1 << 32)}",
      cwd: dir,
      tool_input: { command: command }
    }.merge(extra))
  end

  def call(command, dir, extra = {})
    out, _err, status = Open3.capture3("/bin/sh", HOOK, stdin_data: payload(command, dir, extra))
    [out, status.exitstatus]
  end

  def context(out)
    return "" if out.strip.empty?

    JSON.parse(out).dig("hookSpecificOutput", "additionalContext").to_s
  end

  def test_it_reports_on_a_prose_file_written_by_the_command
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "note.md"), WITH_VIOLATIONS)
      out, code = call("cat > note.md", dir)

      assert_equal 0, code
      assert_includes context(out), "note.md"
      assert_includes context(out), "heading-gerund"
    end
  end

  def test_it_finds_a_path_that_only_appears_inside_a_script
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "gen.rb"), %(File.write("out.md", "x")\n))
      File.write(File.join(dir, "out.md"), WITH_VIOLATIONS)
      out, code = call("ruby gen.rb", dir)

      assert_equal 0, code
      assert_includes context(out), "out.md"
    end
  end

  def test_a_command_that_touches_no_prose_says_nothing
    Dir.mktmpdir do |dir|
      out, code = call("ls -la", dir)

      assert_equal 0, code
      assert_empty out
    end
  end

  def test_a_file_the_command_did_not_touch_is_ignored
    Dir.mktmpdir do |dir|
      path = File.join(dir, "old.md")
      File.write(path, WITH_VIOLATIONS)
      File.utime(Time.now - 7200, Time.now - 7200, path)
      out, code = call("cat old.md", dir)

      assert_equal 0, code
      assert_empty out
    end
  end

  def test_subagent_calls_are_skipped
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "note.md"), WITH_VIOLATIONS)
      out, code = call("cat > note.md", dir, { agent_id: "sub-1" })

      assert_equal 0, code
      assert_empty out
    end
  end

  def test_a_tool_other_than_bash_is_skipped
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "note.md"), WITH_VIOLATIONS)
      body = JSON.generate(tool_name: "Read", cwd: dir, tool_input: { command: "cat note.md" })
      out, _err, status = Open3.capture3("/bin/sh", HOOK, stdin_data: body)

      assert_equal 0, status.exitstatus
      assert_empty out
    end
  end

  def test_an_empty_payload_is_a_silent_no_op
    out, _err, status = Open3.capture3("/bin/sh", HOOK, stdin_data: "")
    assert_equal 0, status.exitstatus
    assert_empty out
  end

  def test_unparseable_input_is_a_silent_no_op
    out, _err, status = Open3.capture3("/bin/sh", HOOK, stdin_data: "not json at all")
    assert_equal 0, status.exitstatus
    assert_empty out
  end

  def test_it_fails_open_when_jq_is_missing
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "note.md"), WITH_VIOLATIONS)
      out, _err, status = Open3.capture3({ "PATH" => dir }, "/bin/sh", HOOK, stdin_data: payload("cat > note.md", dir))

      assert_equal 0, status.exitstatus
      assert_empty out
    end
  end

  def test_the_shared_shim_dispatches_the_shell_hook
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "note.md"), WITH_VIOLATIONS)
      out, _err, status = Open3.capture3("/bin/sh", SHIM, "bash-gate", stdin_data: payload("cat > note.md", dir))

      assert_equal 0, status.exitstatus
      assert_includes context(out), "note.md"
    end
  end

  def test_it_reports_the_event_as_post_tool_use
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "note.md"), WITH_VIOLATIONS)
      out, = call("cat > note.md", dir)

      assert_equal "PostToolUse", JSON.parse(out).dig("hookSpecificOutput", "hookEventName")
    end
  end
end
