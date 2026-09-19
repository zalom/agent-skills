# frozen_string_literal: true

# Tests for the Stop hook. Observe mode must stay silent and bounded; block mode must send
# a turn back exactly once; every failure path must exit 0.

require "minitest/autorun"
require "json"
require "open3"
require "tmpdir"
require "fileutils"
require "date"

class StopHookTest < Minitest::Test
  SHIM = File.expand_path("../run-hook.sh", __dir__)
  CLEAN = "# A heading\n\nThis reply is clean.\n"
  DIRTY = "# A heading\n\nThe colour is grey — and fifteen items.\n"

  def setup
    @home = Dir.mktmpdir
    FileUtils.mkdir_p(File.join(@home, ".claude"))
    @transcript = File.join(@home, "transcript.jsonl")
  end

  def teardown
    FileUtils.rm_rf(@home)
  end

  def state_path
    File.join(@home, ".claude", "plain-writing-observe.json")
  end

  def state
    JSON.parse(File.read(state_path))
  end

  def write_state(data)
    File.write(state_path, JSON.generate(data))
  end

  # A realistic turn: a prompt, narration, a tool call, the tool result coming back as a
  # record of type "user", then the final reply.
  def write_transcript(text, sidechain: false, narration: nil)
    records = [
      { "type" => "user", "message" => { "role" => "user", "content" => "go" } },
      { "type" => "assistant", "isSidechain" => sidechain,
        "message" => { "content" => [{ "type" => "text", "text" => narration.to_s }] } },
      { "type" => "assistant", "isSidechain" => sidechain,
        "message" => { "content" => [{ "type" => "tool_use", "name" => "Bash", "input" => {} }] } },
      { "type" => "user", "toolUseResult" => { "stdout" => "" },
        "message" => { "content" => [{ "type" => "tool_result", "content" => "ok" }] } },
      { "type" => "assistant", "isSidechain" => sidechain,
        "message" => { "content" => [{ "type" => "thinking", "thinking" => "The colour is grey." }] } },
      { "type" => "assistant", "isSidechain" => sidechain,
        "message" => { "content" => [{ "type" => "text", "text" => text }] } }
    ]
    File.write(@transcript, records.map { |r| JSON.generate(r) }.join("\n") + "\n")
  end

  def run_stop(extra = {})
    input = { "session_id" => "s1", "transcript_path" => @transcript }.merge(extra)
    out, _err, status = Open3.capture3({ "HOME" => @home }, SHIM, "stop", stdin_data: JSON.generate(input))
    [out, status.exitstatus]
  end

  def test_observe_mode_stays_silent_and_records_the_findings
    write_transcript(DIRTY)

    out, code = run_stop
    assert_equal 0, code
    assert_empty out
    assert_equal "observe", state["mode"]
    assert_equal 1, state["turns"]
    assert_includes state["rules"].keys, "dashes"
    assert_includes state["rules"].keys, "spelling"
  end

  def test_observe_mode_records_a_clean_turn_without_findings
    write_transcript(CLEAN)

    run_stop
    assert_equal 1, state["turns"]
    assert_empty state["rules"]
  end

  def test_the_tally_keeps_at_most_three_examples_for_one_rule
    write_transcript(DIRTY)
    5.times { run_stop }

    entry = state["rules"]["spelling"]
    assert_operator entry["count"], :>, 3
    assert_equal 3, entry["examples"].length
  end

  def test_off_mode_does_nothing
    write_state("mode" => "off")
    write_transcript(DIRTY)

    out, code = run_stop
    assert_equal 0, code
    assert_empty out
    assert_equal({ "mode" => "off" }, state)
  end

  def test_block_mode_sends_the_turn_back_with_the_findings_and_the_pages
    write_state("mode" => "block", "until" => (Date.today + 7).to_s, "turns" => 0, "rules" => {})
    write_transcript(DIRTY)

    out, code = run_stop
    assert_equal 0, code
    payload = JSON.parse(out)
    assert_equal "block", payload["decision"]
    assert_includes payload["reason"], "dashes"
    assert_includes payload["reason"], "word-list.md"
  end

  def test_block_mode_passes_a_clean_reply
    write_state("mode" => "block", "until" => (Date.today + 7).to_s, "turns" => 0, "rules" => {})
    write_transcript(CLEAN)

    out, = run_stop
    assert_empty out
  end

  def test_it_never_blocks_a_turn_that_was_already_sent_back
    write_state("mode" => "block", "until" => (Date.today + 7).to_s, "turns" => 0, "rules" => {})
    write_transcript(DIRTY)

    out, code = run_stop("stop_hook_active" => true)
    assert_equal 0, code
    assert_empty out
  end

  def test_subagent_turns_are_skipped
    write_transcript(DIRTY, sidechain: true)

    run_stop
    refute_path_exists state_path
  end

  def test_the_observe_window_closes_on_its_own
    write_state("mode" => "observe", "until" => (Date.today - 1).to_s, "turns" => 4, "rules" => {})
    write_transcript(DIRTY)

    out, code = run_stop
    assert_equal 0, code
    assert_empty out
    assert_equal 4, state["turns"]
    assert_empty state["rules"]
  end

  def test_it_reads_past_a_tool_result_to_the_whole_turn
    write_transcript(CLEAN, narration: "The colour is grey.")

    run_stop
    assert_equal 1, state["turns"]
    assert_includes state["rules"].keys, "spelling"
  end

  def test_thinking_blocks_are_not_checked
    write_transcript(CLEAN)

    run_stop
    assert_empty state["rules"]
  end

  def test_a_missing_transcript_is_a_silent_no_op
    out, code = run_stop("transcript_path" => File.join(@home, "no-such.jsonl"))
    assert_equal 0, code
    assert_empty out
  end

  def test_unreadable_input_is_a_silent_no_op
    out, _err, status = Open3.capture3({ "HOME" => @home }, SHIM, "stop", stdin_data: "not json")
    assert_equal 0, status.exitstatus
    assert_empty out
  end
end
