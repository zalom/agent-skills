#!/usr/bin/env ruby
# frozen_string_literal: true

# Stop hook: checks the reply the agent just finished, so prose that never touches a file
# is covered by the same rules as prose that does. The gate sees writes and publishes; a
# report typed straight into the session is seen by nothing else.
#
# Reached through run-hook.sh, which Claude Code registers as `<shim> stop`.
#
# Three modes, held in one state file so turning the hook off never means editing
# settings.json:
#
#   observe  runs the checker and records a tally. Nothing is ever sent back. This is the
#            shipped default, and it ends on its own after OBSERVE_DAYS.
#   block    sends the turn back once with the findings and the pages that govern them.
#   off      does nothing at all.
#
# The tally is bounded by construction: one entry per rule, at most EXAMPLE_LIMIT examples
# of EXAMPLE_CHARS characters each, so the file cannot grow past a few kilobytes however
# many replies it sees.
#
# Never blocks twice: Claude Code sets stop_hook_active on the turn that a Stop hook already
# sent back. Subagent turns are skipped, keyed on the isSidechain flag in the transcript.
#
# Fails open everywhere: any error, any unexpected payload, and the turn ends untouched.

require "date"
require "json"
require "tmpdir"

require_relative "lint"

STATE = File.join(Dir.home, ".claude", "plain-writing-observe.json")
OBSERVE_DAYS = 7
EXAMPLE_LIMIT = 3
EXAMPLE_CHARS = 160
TAIL_BYTES = 512 * 1024

# rule => the page that governs it, named for the agent to open
PAGES = {
  "dashes" => "dashes.md",
  "spelling" => "word-list.md",
  "heading-levels" => "headings.md",
  "heading-case" => "headings.md",
  "heading-gerund" => "headings.md",
  "heading-link" => "headings.md",
  "heading-number" => "headings.md",
  "heading-empty" => "headings.md",
  "table-caption" => "tables.md",
  "table-scope" => "tables.md",
  "table-merge" => "tables.md",
  "cell-br" => "tables.md",
  "numbers" => "numbers.md"
}.freeze

def payload
  raw = $stdin.read
  return nil if raw.nil? || raw.strip.empty?

  JSON.parse(raw)
rescue StandardError
  nil
end

def state
  JSON.parse(File.read(STATE))
rescue StandardError
  {}
end

def fresh_state
  {
    "mode" => "observe",
    "until" => (Date.today + OBSERVE_DAYS).to_s,
    "reported" => false,
    "turns" => 0,
    "rules" => {}
  }
end

def save(data)
  File.write(STATE, JSON.pretty_generate(data) + "\n")
rescue StandardError
  nil
end

def window_open?(data)
  Date.parse(data["until"].to_s) >= Date.today
rescue StandardError
  false
end

# The last N bytes hold the current turn in every realistic session, and reading them keeps
# the hook off the critical path of a session whose transcript has grown to megabytes.
def tail_lines(path)
  size = File.size(path)
  body = File.open(path, "rb") do |f|
    f.seek([size - TAIL_BYTES, 0].max)
    f.read
  end
  lines = body.to_s.force_encoding("UTF-8").lines
  lines.shift if size > TAIL_BYTES
  lines
rescue StandardError
  []
end

# Everything the agent said in this turn: the text blocks of the assistant records that
# follow the last user record. Subagent records carry isSidechain and are left out.
def reply_text(path)
  return nil unless path && File.file?(path)

  out = []
  tail_lines(path).reverse_each do |line|
    record = begin
      JSON.parse(line)
    rescue StandardError
      next
    end
    break if record["type"] == "user"
    next unless record["type"] == "assistant"
    next if record["isSidechain"]

    blocks = record.dig("message", "content")
    next unless blocks.is_a?(Array)

    out.unshift(blocks.select { |b| b["type"] == "text" }.map { |b| b["text"].to_s }.join)
  end

  text = out.join("\n").strip
  text.empty? ? nil : text
end

def findings_for(text)
  file = File.join(Dir.tmpdir, "plain-writing-reply-#{Process.pid}.md")
  File.write(file, text)
  Linter.new(file).run
ensure
  File.delete(file) if file && File.exist?(file)
end

def record(data, findings)
  data["turns"] = data["turns"].to_i + 1
  findings.each do |finding|
    entry = data["rules"][finding.rule] ||= { "count" => 0, "examples" => [] }
    entry["count"] += 1
    next if entry["examples"].length >= EXAMPLE_LIMIT

    entry["examples"] << finding.message.to_s[0, EXAMPLE_CHARS]
  end
  data
end

def reason(findings)
  lines = findings.first(10).map { |f| "  [#{f.rule}] line #{f.line}: #{f.message}" }
  pages = findings.map { |f| PAGES[f.rule] }.compact.uniq
  <<~MSG
    The plain-writing checker found #{findings.length} violation#{'s' if findings.length != 1} in the reply you just wrote:

    #{lines.join("\n")}

    Open #{pages.join(', ')} under the skill's references/google/ directory, fix every
    finding, and send the reply again. Where the guide genuinely permits the usage, keep it
    and say which rule you are reading it against.
  MSG
end

begin
  data = payload
  exit 0 if data.nil?
  exit 0 if data["stop_hook_active"]

  current = state
  current = fresh_state if current["mode"].nil?
  exit 0 if current["mode"] == "off"

  text = reply_text(data["transcript_path"])
  exit 0 if text.nil?

  findings = findings_for(text)

  if current["mode"] == "block" && !findings.empty?
    save(record(current, findings))
    puts JSON.generate("decision" => "block", "reason" => reason(findings))
    exit 0
  end

  save(record(current, findings)) if window_open?(current)
  exit 0
rescue StandardError, SystemStackError
  exit 0
end
