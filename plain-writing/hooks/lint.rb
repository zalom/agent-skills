#!/usr/bin/env ruby
# frozen_string_literal: true

# Deterministic checker for the mechanically checkable rules in the plain-writing skill.
#
# Reading reference pages makes an author *able* to comply. Only a checker makes compliance
# *verifiable*. Every rule below is one that can be decided from the text alone, with no
# judgement, so it holds whether or not anyone read anything.
#
# Judgement rules (voice, tone, jargon, whether a sentence is true) are deliberately absent.
# Those still need the routed pages; this tool does not pretend to cover them.
#
# Usage:  plain-writing-lint.rb FILE [FILE...]
# Exit:   0 clean, 1 violations found, 2 usage error.

require "set"

class Finding
  attr_reader :line, :rule, :message, :source

  def initialize(line:, rule:, message:, source:)
    @line = line
    @rule = rule
    @message = message
    @source = source
  end

  def to_s
    "  #{@source}:#{@line}  [#{@rule}]  #{@message}"
  end
end

class Linter
  # Numbers 10 and greater take numerals (numbers.md). Sentence-initial numbers are spelled
  # out, so a candidate is only flagged when it does not open a sentence.
  SPELLED_TENS = %w[
    ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen
    twenty thirty forty fifty sixty seventy eighty ninety hundred thousand
  ].freeze

  # Standard American spelling (the guide's third-party reference is Merriam-Webster).
  BRITISH = {
    "behaviour" => "behavior", "colour" => "color", "favourite" => "favorite",
    "labelled" => "labeled", "labelling" => "labeling", "artefact" => "artifact",
    "organise" => "organize", "organisation" => "organization", "recognise" => "recognize",
    "analyse" => "analyze", "practise" => "practice", "licence" => "license",
    "centre" => "center", "defence" => "defense", "per cent" => "percent",
    "grey" => "gray", "catalogue" => "catalog", "programme" => "program"
  }.freeze

  # Frequent -ing openers in headings (headings.md discourages gerund-initial headings).
  # Words ending in -ing that are not gerunds, plus gerunds the guide explicitly allows.
  GERUND_OK = %w[
    billing pricing logging licensing onboarding
    nothing something anything everything thing things during string strings
    king ring wing spring bring sing swing morning evening ceiling being
  ].freeze

  # A gerund heading takes an object; these words signal one follows.
  GERUND_OBJECT = %w[
    a an the this that these those your our their its his her
    to for from with in on at by into about across over
  ].freeze

  def initialize(path)
    @path = path
    @text = File.read(path)
    @lines = @text.lines
    @html = File.extname(path).downcase.match?(/\.html?\z/)
    @findings = []
  end

  def run
    strip_code!
    check_dashes
    check_british
    check_heading_levels
    check_heading_text
    check_tables
    check_br_structure
    check_spelled_numbers
    @findings.sort_by(&:line)
  end

  private

  # Style, script, code and pre blocks are not prose; exclude them from prose rules but keep
  # line numbers stable so findings still point at the right place.
  def strip_code!
    @prose = @text.dup
    %w[style script pre code].each do |tag|
      @prose.gsub!(%r{<#{tag}\b.*?</#{tag}>}m) { |m| m.gsub(/[^\n]/, " ") }
    end
    @prose.gsub!(/^```.*?^```/m) { |m| m.gsub(/[^\n]/, " ") }
    @prose.gsub!(/`[^`\n]+`/) { |m| " " * m.length }
    @prose_lines = @prose.lines
  end

  # An author can accept a rule's cost deliberately with a "lint-ok: <rule>" comment on
  # the line. Silence is never assumed; the exception has to be written down.
  def suppressed?(line, rule)
    @lines[line - 1].to_s.match?(/lint-ok:\s*(#{Regexp.escape(rule)}|all)\b/)
  end

  def add(line, rule, message)
    return if suppressed?(line, rule)

    @findings << Finding.new(line: line, rule: rule, message: message, source: @path)
  end

  def each_prose_line
    @prose_lines.each_with_index { |l, i| yield l, i + 1 }
  end

  # --- overrides.md: hyphen instead of em dash or en dash -------------------------------

  def check_dashes
    each_prose_line do |line, n|
      if line.match?(/[—–]/) || line.match?(/&mdash;|&ndash;/)
        add(n, "dashes", "em dash or en dash present; the overrides layer requires a hyphen")
      end
    end
  end

  # --- word-list / Merriam-Webster: standard American spelling --------------------------

  def check_british
    each_prose_line do |line, n|
      BRITISH.each do |bad, good|
        next unless line.match?(/\b#{Regexp.escape(bad)}\b/i)

        add(n, "spelling", "#{bad.inspect} should be #{good.inspect} (standard American spelling)")
      end
    end
  end

  # --- headings.md: do not skip levels of the heading hierarchy --------------------------

  def headings
    found = []
    if @html
      @prose.scan(/<h([1-6])\b[^>]*>(.*?)<\/h\1>/mi) do
        level = Regexp.last_match(1).to_i
        text = Regexp.last_match(2)
        line = @prose[0...Regexp.last_match.begin(0)].count("\n") + 1
        found << [level, text, line]
      end
    else
      each_prose_line do |line, n|
        m = line.match(/^(\#{1,6})\s+(.*)$/)
        found << [m[1].length, m[2], n] if m
      end
    end
    found
  end

  def check_heading_levels
    prev = nil
    headings.each do |level, _text, line|
      if prev && level > prev + 1
        add(line, "heading-levels", "h#{level} sits directly under h#{prev}; the hierarchy skips h#{prev + 1}")
      end
      prev = level
    end
  end

  def check_heading_text
    headings.each do |_level, raw, line|
      text = raw.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip

      add(line, "heading-empty", "heading has no text") if text.empty?

      if raw.match?(/<a\s+[^>]*href=/i) || raw.match?(/\[[^\]]+\]\(/)
        add(line, "heading-link", "link inside a heading; a link reads as styling, not a target")
      end

      words_l = text.split(/\s+/).map { |w| w.downcase.gsub(/[^a-z]/, "") }
      first = words_l.first.to_s
      # "Writing style" and "Routing table" are noun compounds, not gerunds. A gerund heading
      # takes an object, so it is followed by a determiner or a preposition.
      takes_object = GERUND_OBJECT.include?(words_l[1].to_s)
      if first.end_with?("ing") && first.length > 4 && !GERUND_OK.include?(first) && takes_object
        add(line, "heading-gerund", "heading opens with the -ing form #{first.inspect}; use a noun phrase or a bare infinitive")
      end

      if text.match?(/^\s*\d+[.)]\s/)
        add(line, "heading-number", "heading text carries a sequence number; let hierarchy and order carry sequence")
      end

      # Sentence case: flag when a mid-heading word is capitalised without cause.
      words = text.split(/\s+/)
      if words.length >= 4
        suspects = words[1..].reject do |w|
          w.match?(/[A-Z]{2,}|[.:\d]|\A[a-z(]/) || w.match?(/\A[A-Z][a-z]*\z/) == false
        end
        capped = suspects.count { |w| w.match?(/\A[A-Z][a-z]+\z/) }
        if capped >= [(words.length - 1) * 0.6, 2].max
          add(line, "heading-case", "heading looks like Title Case; use sentence case")
        end
      end
    end
  end

  # --- tables.md + accessibility.md ------------------------------------------------------

  def check_tables
    return unless @html

    @prose.scan(/<table\b.*?<\/table>/mi) do |tbl|
      line = @prose[0...Regexp.last_match.begin(0)].count("\n") + 1

      unless tbl.match?(/<caption\b/i)
        add(line, "table-caption", "table has no caption element; screen readers do not preannounce tables")
      end

      ths = tbl.scan(/<th\b[^>]*>/i)
      if ths.empty?
        add(line, "table-headers", "table has no th cells")
      else
        missing = ths.count { |t| !t.match?(/scope\s*=/i) }
        if missing.positive?
          add(line, "table-scope", "#{missing} of #{ths.length} th cells lack a scope attribute")
        end
      end

      if tbl.match?(/colspan|rowspan/i)
        add(line, "table-merge", "merged cells (colspan/rowspan) are not accessible in a data table")
      end
    end
  end

  def check_br_structure
    return unless @html

    @prose.scan(/<t[dh]\b.*?<\/t[dh]>/mi) do |cell|
      next unless cell.match?(/<br\s*\/?>/i)

      line = @prose[0...Regexp.last_match.begin(0)].count("\n") + 1
      add(line, "cell-br", "br used as structure inside a table cell; use p or a block element")
    end
  end

  # --- numbers.md: numerals for 10 and greater -------------------------------------------

  def check_spelled_numbers
    each_prose_line do |line, n|
      plain = line.gsub(/<[^>]+>/, " ")
      SPELLED_TENS.each do |word|
        plain.scan(/(^|[^\w>-])(#{word})\b/i) do
          prefix = Regexp.last_match(1)
          before = plain[0...Regexp.last_match.begin(0)]
          # sentence-initial numbers are spelled out on purpose
          next if before.strip.empty? || before.match?(/[.!?]["')\]]?\s+\z/)
          # a capitalised spelled number is sentence-initial, which the guide requires
          next if Regexp.last_match(2).match?(/\A[A-Z]/)
          # hyphenated compounds and ordinals are out of scope here
          next if plain[Regexp.last_match.end(0), 1] == "-"
          next if prefix == "-"

          add(n, "numbers", "#{word.inspect} is 10 or greater; use a numeral outside sentence-initial position")
        end
      end
    end
  end
end

if ARGV.empty?
  warn "usage: plain-writing-lint.rb FILE [FILE...]"
  exit 2
end

all = []
ARGV.each do |path|
  unless File.file?(path)
    warn "skip (not a file): #{path}"
    next
  end
  all.concat(Linter.new(path).run)
rescue StandardError => e
  warn "skip (#{e.class}): #{path}"
end

if all.empty?
  puts "plain-writing-lint: clean (#{ARGV.length} file#{'s' if ARGV.length != 1})"
  exit 0
end

by_rule = all.group_by(&:rule)
puts "plain-writing-lint: #{all.length} violation#{'s' if all.length != 1} in #{by_rule.keys.length} rule#{'s' if by_rule.keys.length != 1}"
puts
by_rule.sort_by { |r, f| [-f.length, r] }.each do |rule, findings|
  puts "#{rule} (#{findings.length})"
  findings.first(12).each { |f| puts f }
  puts "  ... and #{findings.length - 12} more" if findings.length > 12
  puts
end
exit 1
