# frozen_string_literal: true

# Tests for the shorthand rule in lint.rb: a bare id such as D30 is a token standing for a
# thing the reader was never told about, so it may appear only inside parentheses after the
# plain words that name it.

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../lint"

class LintShorthandTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def findings(text)
    path = File.join(@dir, "reply.md")
    File.write(path, text)
    Linter.new(path).run.select { |f| f.rule == "shorthand" }
  end

  def test_a_bare_id_in_prose_is_a_finding
    found = findings("Record which rulings D30 in full and D21 supersede.\n")
    assert_equal %w[D30 D21], found.map { |f| f.message[/"([^"]+)"/, 1] }
    assert_equal [1, 1], found.map(&:line)
  end

  def test_a_letter_suffix_and_a_short_id_are_findings
    assert_equal 2, findings("D38g for the order, and I5 before the views node.\n").length
  end

  def test_an_id_inside_parentheses_after_plain_words_passes
    assert_empty findings("The ruling that keeps three databases (D38) stands.\n")
    assert_empty findings("Rule who owns the graph file (issue I5) before the views node (N5).\n")
  end

  def test_an_id_in_a_code_span_or_fenced_block_passes
    assert_empty findings("Run `plastic auto take D30` and read `N1`.\n")
    assert_empty findings("```\nD30 N1\n```\n")
  end

  def test_an_id_inside_a_word_a_path_or_a_tag_passes
    assert_empty findings("See MD5 sums, /tmp/D30/out, item-D30, and v2 of the <h1> tag.\n")
    assert_empty findings("<section id=\"D30\">text</section>\n")
  end

  def test_lint_ok_suppresses_the_rule
    assert_empty findings("Press F1 for help. lint-ok: shorthand\n")
  end
end
