# frozen_string_literal: true

require "minitest/autorun"
require "json"
require "open3"
require "tmpdir"
require "fileutils"

class GateTest < Minitest::Test
  GATE = File.expand_path("../gate.rb", __dir__)
  PAGE_BODY = "PAGE BODY SENTINEL"

  def setup
    @home = Dir.mktmpdir
    refs = File.join(@home, ".claude", "skills", "plain-writing", "references", "google")
    FileUtils.mkdir_p(refs)
    %w[highlights active-voice headings].each { |page| File.write(File.join(refs, "#{page}.md"), PAGE_BODY) }
    @doc = File.join(@home, "doc.md")
  end

  def teardown
    FileUtils.rm_rf(@home)
  end

  def run_gate(extra = {})
    input = { "session_id" => "s1", "tool_name" => "Write",
              "tool_input" => { "file_path" => @doc, "content" => "# Title\n\nPlain text.\n" } }.merge(extra)
    out, = Open3.capture2({ "HOME" => @home }, "ruby", GATE, stdin_data: JSON.generate(input))
    out
  end

  def context(out)
    JSON.parse(out).dig("hookSpecificOutput", "additionalContext")
  end

  def test_subagent_tool_call_gets_nothing
    File.write(@doc, "The colour is grey.\n")

    assert_empty run_gate("agent_id" => "a773fb817ff8b112d")
  end

  def test_main_session_gets_page_names_without_page_text
    text = context(run_gate)

    assert_includes text, "highlights, active-voice, headings"
    refute_includes text, PAGE_BODY
  end

  def test_pointer_once_per_session_and_findings_every_call
    File.write(@doc, "The colour is grey.\n")
    first = context(run_gate)
    second = context(run_gate)

    assert_includes first, "more rules than this session holds"
    refute_includes second, "more rules than this session holds"
    assert_includes second, "colour"
  end
end
