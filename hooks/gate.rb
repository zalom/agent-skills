#!/usr/bin/env ruby
# frozen_string_literal: true

# PreToolUse gate for the writing-style skill.
#
# Two jobs, deliberately separate:
#
#   DELIVERY. Nothing from the guide sits in context all session. Instead, at the
#   moment a document is written or published, this hook works out which devices the draft
#   actually uses and injects the FULL TEXT of the pages that govern them. No distillation,
#   so nothing can drift from the source, and no standing context cost.
#
#   ENFORCEMENT. It runs the deterministic checker over the same draft and reports every
#   finding alongside the rules. Findings are advisory: nothing is ever blocked. BLOCKING_TOOLS
#   is the switch that would make a listed tool refuse instead, and it is deliberately empty.
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

# Too large to inject, and useless injected: word-list is a lookup table you grep, and
# whats-new is the guide's own changelog, which it states is not a source of rules.
NEVER_INJECT = %w[word-list whats-new].freeze

MAX_BUNDLE = 120_000 # bytes of reference text; a hard ceiling on one injection

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
  (ALWAYS + matched).uniq - NEVER_INJECT
end

def bundle(pages)
  used = []
  body = +""
  pages.each do |page|
    file = File.join(REF_DIR, "#{page}.md")
    next unless File.file?(file)

    content = File.read(file)
    break if body.bytesize + content.bytesize > MAX_BUNDLE

    used << page
    body << "\n\n===== #{page}.md =====\n\n" << content
  end
  [used, body]
end

def lint(path)
  return [true, ""] unless path && File.file?(path) && File.file?(LINTER)

  out = `ruby #{LINTER.inspect} #{path.inspect} 2>&1`
  [$?.success?, out.to_s.strip]
rescue StandardError
  [true, ""] # a broken checker must never block work
end

# Records that this document has already received this page set in this session, so a
# republish does not re-inject the same reference text. Enforcement is never cached: the
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

# --- delivery --------------------------------------------------------------------------

pages = pages_for(text)
used, refs = bundle(pages)
exit 0 if used.empty?

# Deliver a given page set for a given document once per session. A republish does not pay
# for the same reference text again; a draft that grows a new device does, because the page
# set changes and so does the key.
exit 0 if delivered_before?(data, path, used)

label = tool == "Artifact" ? "publishing this artifact" : "writing #{path}"
note  = clean ? "" : "\n\nThe deterministic checker also reports:\n\n#{findings}\n"

emit_allow(<<~MSG)
  WRITING-STYLE RULES for #{label}

  These are the pages of the style guide that govern the devices this draft actually uses.
  They are delivered here so they do not have to be remembered or looked up. Apply them to
  this document before it ships, and say which ones you applied.

  Pages included: #{used.join(', ')}
  For a single word's spelling or usage, grep #{File.join(REF_DIR, 'word-list.md')} rather
  than reading it.#{note}
  #{refs}
MSG
