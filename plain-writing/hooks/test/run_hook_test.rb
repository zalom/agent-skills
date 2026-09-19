# frozen_string_literal: true

# Tests for run-hook.sh, the shared entry point. Every failure mode must exit 0 and print
# nothing, so a broken install never blocks a session or a tool call.

require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"

class RunHookTest < Minitest::Test
  SHIM = File.expand_path("../run-hook.sh", __dir__)

  def call(*args, stdin: "{}")
    out, _err, status = Open3.capture3(SHIM, *args, stdin_data: stdin)
    [out, status.exitstatus]
  end

  def test_no_argument_is_a_silent_no_op
    out, code = call
    assert_equal 0, code
    assert_empty out
  end

  def test_unknown_hook_name_is_a_silent_no_op
    out, code = call("no-such-hook")
    assert_equal 0, code
    assert_empty out
  end

  def test_a_name_outside_the_allowed_characters_is_refused
    out, code = call("../../../etc/passwd")
    assert_equal 0, code
    assert_empty out
  end

  def test_it_runs_the_named_hook_body
    out, code = call("session-start")
    assert_equal 0, code
    assert_includes out, "hookSpecificOutput"
  end

  def test_it_passes_arguments_through_to_the_hook_body
    Dir.mktmpdir do |dir|
      out, code = call("session-start", File.join(dir, "no-such-skill"))
      assert_equal 0, code
      assert_includes out, "not found"
    end
  end

  def test_it_resolves_its_own_directory_through_a_symlink
    Dir.mktmpdir do |dir|
      link = File.join(dir, "plain-writing")
      File.symlink(SHIM, link)

      out, _err, status = Open3.capture3(link, "session-start", stdin_data: "{}")
      assert_equal 0, status.exitstatus
      assert_includes out, "hookSpecificOutput"
    end
  end

  def test_it_fails_open_when_ruby_is_missing
    Dir.mktmpdir do |dir|
      out, _err, status = Open3.capture3({ "PATH" => dir }, "/bin/sh", SHIM, "session-start", stdin_data: "{}")
      assert_equal 0, status.exitstatus
      assert_empty out
    end
  end
end
