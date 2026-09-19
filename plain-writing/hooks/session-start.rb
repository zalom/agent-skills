#!/usr/bin/env ruby
# frozen_string_literal: true

# SessionStart hook: injects the plain-writing skill activation set into the session.
# Reached through run-hook.sh, which Claude Code registers as `<shim> session-start`.
#
# Finds the skill wherever it is installed: an explicit root, then the skill this hook ships
# inside, then ~/.claude/skills, then the plugin installed from the zalom-skills marketplace,
# then that marketplace's own checkout.
#
# The personal overrides layer is never shipped with the skill, so when the skill directory
# has no references/overrides.md the hook reads ~/.claude/plain-writing-overrides.md instead.
#
# Fails open: never a non-zero exit, never a raise.

require "date"
require "json"

LIMIT = 16_000
PREAMBLE = "The plain-writing skill is loaded; follow it for every text you write, including replies."
OVERRIDES = "references/overrides.md"
FILES = [
  "SKILL.md",
  "references/google/highlights.md",
  OVERRIDES
].freeze
KEEP_ORDER = [
  OVERRIDES,
  "SKILL.md",
  "references/google/highlights.md"
].freeze

PERSONAL_OVERRIDES = File.join(Dir.home, ".claude", "plain-writing-overrides.md")
OBSERVE_STATE = File.join(Dir.home, ".claude", "plain-writing-observe.json")
PLUGIN_CACHE = File.join(Dir.home, ".claude", "plugins", "cache", "zalom-skills", "plain-writing")
MARKETPLACE = File.join(Dir.home, ".claude", "plugins", "marketplaces", "zalom-skills", "plain-writing")
SHIPPED_ROOT = File.expand_path("..", __dir__)

def newest_plugin_version
  Dir.glob(File.join(PLUGIN_CACHE, "*")).select { |path| File.file?(File.join(path, "SKILL.md")) }
     .max_by { |path| Gem::Version.new(File.basename(path)) rescue Gem::Version.new("0") }
end

def candidate_roots
  [
    SHIPPED_ROOT,
    File.join(Dir.home, ".claude", "skills", "plain-writing"),
    newest_plugin_version,
    MARKETPLACE
  ].compact
end

def default_root
  candidate_roots.find { |path| File.file?(File.join(path, "SKILL.md")) } || candidate_roots.first
end

def skipped_notice(skipped)
  "These files were skipped for size: #{skipped.join(', ')}. Invoke the plain-writing skill to read them."
end

def fit(sections)
  used = PREAMBLE.length + skipped_notice(sections.keys).length + 1
  kept = []
  KEEP_ORDER.each do |rel|
    next unless sections[rel]

    size = sections[rel].length + 1
    next if used + size >= LIMIT

    kept << rel
    used += size
  end
  skipped = sections.keys - kept
  ([PREAMBLE, skipped_notice(skipped)] + sections.select { |rel, _| kept.include?(rel) }.values).join("\n")
end

# The Stop hook watches replies for a week and tallies what it would have caught. When that
# week is over, say so once, here, rather than leaving a file for someone to remember.
def observe_report
  return nil unless File.file?(OBSERVE_STATE)

  data = JSON.parse(File.read(OBSERVE_STATE))
  return nil unless data["mode"] == "observe"
  return nil if data["reported"]
  return nil if Date.parse(data["until"].to_s) >= Date.today

  rules = data["rules"] || {}
  total = rules.values.sum { |entry| entry["count"].to_i }
  top = rules.max_by { |_rule, entry| entry["count"].to_i }

  data["reported"] = true
  File.write(OBSERVE_STATE, JSON.pretty_generate(data) + "\n")

  summary = if total.zero?
              "found nothing in #{data['turns']} replies"
            else
              "found #{total} violations in #{data['turns']} replies, most often #{top[0]} (#{top[1]['count']})"
            end
  "The plain-writing Stop hook watched for a week and #{summary}. " \
    "Ask the user whether to set \"mode\": \"block\" in #{OBSERVE_STATE}."
rescue StandardError
  nil
end

def not_found(root)
  puts JSON.generate({ "systemMessage" => "plain-writing skill not found at #{root}; nothing injected" })
  exit 0
end

def without_frontmatter(body)
  body.sub(/\A---\r?\n.*?\r?\n---\r?\n/m, "")
end

def section(rel, body)
  "## File: #{rel}\n\n#{without_frontmatter(body).strip}\n"
end

def source_for(rel, resolved)
  in_skill = File.join(resolved, rel)
  return in_skill if File.file?(in_skill)
  return PERSONAL_OVERRIDES if rel == OVERRIDES && File.file?(PERSONAL_OVERRIDES)

  nil
end

begin
  begin
    $stdin.read unless $stdin.tty?
  rescue StandardError
    nil
  end

  root = ARGV[0] || ENV["PLAIN_WRITING_ROOT"] || default_root
  root = File.expand_path(root)
  resolved = begin
    File.realpath(root)
  rescue StandardError
    root
  end

  skill_path = File.join(resolved, "SKILL.md")
  not_found(root) unless File.directory?(resolved) && File.file?(skill_path)

  sources = FILES.to_h { |rel| [rel, source_for(rel, resolved)] }.compact
  sections = sources.to_h { |rel, path| [rel, section(rel, File.read(path, encoding: "UTF-8"))] }
  context = ([PREAMBLE] + sections.values).join("\n")
  context = fit(sections) if context.length >= LIMIT

  report = observe_report
  context = "#{report}\n#{context}" if report

  payload = {
    "hookSpecificOutput" => {
      "hookEventName" => "SessionStart",
      "additionalContext" => context
    }
  }
  puts JSON.generate(payload)
  exit 0
rescue StandardError, SystemStackError
  label = root || "unknown"
  puts JSON.generate({ "systemMessage" => "plain-writing skill not found at #{label}; nothing injected" })
  exit 0
end
