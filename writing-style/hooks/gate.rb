#!/usr/bin/env ruby
# frozen_string_literal: true

# PreToolUse gate for the writing-style skill.
#
# Two jobs, deliberately separate:
#
#   POINTER. Nothing from the guide sits in context all session, and no page text is ever
#   injected. At the moment a document is written or published, this hook works out which
#   devices the draft actually uses and names the pages that govern them, with their paths,
#   so the agent knows there is more to the guide and opens what it has not read.
#
#   ENFORCEMENT. It runs the deterministic checker over the same draft and reports every
#   finding alongside the rules. Findings are advisory: nothing is ever blocked. BLOCKING_TOOLS
#   is the switch that would make a listed tool refuse instead, and it is deliberately empty.
#
# Subagent sessions are skipped entirely: Claude Code sets agent_id in the hook input only
# when a subagent makes the tool call.
#
# Fails open everywhere: any error, any unexpected payload, and the tool call proceeds.

require "json"
require "digest"

SKILL_DIR = File.join(Dir.home, ".claude", "skills", "writing-style")
REF_DIR   = File.join(SKILL_DIR, "references", "google")
LINTER    = File.expand_path("lint.rb", __dir__)

# Tools that refuse outright on a violation. Empty on purpose: the gate informs, it does
# not block. Add "Artifact" here to make publishing refuse a document with violations.
BLOCKING_TOOLS = %w[].freeze
ADVISORY_TOOLS = %w[Artifact Write Edit NotebookEdit].freeze

PROSE_EXT = %w[.md .markdown .html .htm .txt .rst .adoc].freeze

# device present in the draft => page that governs it
DEVICES = {
  "headings"         => /^\s{0,3}\#{1,6}\s|<h[1-6][\s>]/i,
  "tables"           => /^\s*\|.*\||<table[\s>]/i,
  "lists"            => /^\s*[-*+]\s|^\s*\d+\.\s|<[uo]l[\s>]/i,
  "numbers"          => /\d/,
  "code-in-text"     => /`|<code[\s>]/i,
  "accessibility"    => /<img|<svg|<table|!\[/i,
  "dates-times"      => /\b\d{4}-\d{2}-\d{2}\b/,
  "cross-references" => /\[[^\]]+\]\(|<a\s+[^>]*href=/i,
  "code-samples"     => /^```|<pre[\s>]/i,
  "images"           => /<img|!\[/i,
  "procedures"       => /^\s*1\.\s.*\n\s*2\.\s/m
}.freeze

ALWAYS = %w[highlights active-voice].freeze

def payload
  raw = $stdin.read
  return nil if raw.nil? || raw.strip.empty?

  JSON.parse(raw)
rescue StandardError
  nil
end

def subagent?(data)
  !data["agent_id"].to_s.empty?
end

def target(data)
  input = data["tool_input"] || {}
  input["file_path"] || input["notebook_path"]
end

def prose?(path)
  return false if path.nil?

  PROSE_EXT.include?(File.extname(path).downcase)
end

def draft_text(data, path)
  input = data["tool_input"] || {}
  body = input["content"] || input["new_string"]
  return body if body && !body.empty?
  return File.read(path) if path && File.file?(path) && File.size(path) < 2_000_000

  nil
rescue StandardError
  nil
end

def pages_for(text)
  matched = if text.nil? || text.empty?
              DEVICES.keys
            else
              DEVICES.select { |_page, re| text.match?(re) }.keys
            end
  (ALWAYS + matched).uniq.select { |page| File.file?(File.join(REF_DIR, "#{page}.md")) }
end

def lint(path)
  return [true, ""] unless path && File.file?(path) && File.file?(LINTER)

  out = `ruby #{LINTER.inspect} #{path.inspect} 2>&1`
  [$?.success?, out.to_s.strip]
rescue StandardError
  [true, ""] # a broken checker must never block work
end

# Records that this document has already been pointed at this page set in this session, so
# a republish does not repeat the pointer. Enforcement is never cached: the
# checker above runs on every single call.
def delivered_before?(data, path, pages)
  session = data["session_id"] || ENV["CLAUDE_CODE_SESSION_ID"] || "nosession"
  key = [session, path, pages.sort.join(",")].join("|")
  digest = Digest::SHA256.hexdigest(key)[0, 32]

  dir = File.join(Dir.home, ".claude", ".writing-style-cache")
  Dir.mkdir(dir) unless Dir.exist?(dir)

  stamp = File.join(dir, "#{digest}.seen")
  return true if File.exist?(stamp)

  File.write(stamp, Time.now.to_i.to_s)

  # keep the cache from growing without bound
  old = Dir.glob(File.join(dir, "*.seen")).select { |f| File.mtime(f) < Time.now - 86_400 }
  old.each { |f| File.delete(f) rescue nil }

  false
rescue StandardError
  false # cache trouble must never suppress delivery
end

def emit_allow(context)
  puts JSON.generate(
    hookSpecificOutput: { hookEventName: "PreToolUse", additionalContext: context }
  )
  exit 0
end

def block(reason)
  warn reason
  exit 2 # PreToolUse: blocks the tool call and returns stderr to the model
end

data = payload
exit 0 if data.nil?
exit 0 if subagent?(data)
exit 0 unless Dir.exist?(REF_DIR)

tool = data["tool_name"].to_s
blocking = BLOCKING_TOOLS.include?(tool)
advisory = ADVISORY_TOOLS.include?(tool)
exit 0 unless blocking || advisory

path = target(data)
exit 0 if advisory && !prose?(path)

text = draft_text(data, path)
clean, findings = lint(path)

# --- enforcement -----------------------------------------------------------------------

if blocking && !clean && !findings.empty?
  block(<<~MSG)
    BLOCKED by the writing-style gate. This document is not publishable as written.

    #{findings}

    Fix each finding, or, where the guide genuinely permits the usage, record the exception
    on that line with a "lint-ok: <rule>" comment and publish again. Do not disable the gate.
  MSG
end

# --- pointer ---------------------------------------------------------------------------

pages = pages_for(text)
exit 0 if pages.empty?

# Point a given document at a given page set once per session. A draft that grows a new
# device gets a new pointer, because the page set changes and so does the key. Findings are
# reported on every call.
fresh = !delivered_before?(data, path, pages)
exit 0 unless fresh || !clean

label   = tool == "Artifact" ? "publishing this artifact" : "writing #{path}"
pointer = <<~POINTER
  The style guide has more rules than this session holds. The pages that govern the devices
  this draft uses are #{pages.join(', ')}, under #{REF_DIR}/<page>.md. Open each one you
  have not read in this session before this document ships. For one word's spelling or usage,
  grep #{File.join(REF_DIR, 'word-list.md')} rather than reading it.
POINTER
note = clean ? "" : "The deterministic checker reports:\n\n#{findings}\n"

emit_allow("WRITING-STYLE for #{label}\n\n#{fresh ? pointer : ''}#{fresh && !clean ? "\n" : ''}#{note}")
