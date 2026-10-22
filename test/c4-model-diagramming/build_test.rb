require "minitest/autorun"
require "rexml/document"
require "tmpdir"

require_relative "../support/project_fixtures"
require File.join(C4_SKILL_ROOT, "scripts/build")

class C4BuildTest < Minitest::Test
  DIAGRAM_TYPES = %w[system-context container component system-landscape dynamic deployment].freeze

  def test_build_writes_every_key_and_one_example_per_diagram_type
    Dir.mktmpdir do |out|
      files = C4::Build.write(out)

      assert_equal C4::Build::KEYS.size, files.count { |f| f.include?("/keys/") }
      assert_equal DIAGRAM_TYPES.sort, files.select { |f| f.include?("/examples/") }.map { |f| File.basename(f, ".svg") }.sort
    end
  end

  def test_every_svg_is_well_formed_and_labelled
    Dir.mktmpdir do |out|
      C4::Build.write(out).each do |file|
        svg = REXML::Document.new(File.read(file)).root

        assert_equal "svg", svg.name, file
        refute_empty svg.attributes["aria-label"].to_s, "#{file}: no aria-label"
        assert_includes File.read(file), "prefers-color-scheme:dark", "#{file}: no dark set"
      end
    end
  end

  def test_every_example_has_a_title_and_a_key
    Dir.mktmpdir do |out|
      C4::Build.write(out).select { |f| f.include?("/examples/") }.each do |file|
        content = File.read(file)

        assert_includes content, ">Key</text>", "#{file}: no key"
        assert_match(/letter-spacing="1.2"/, content, "#{file}: no title")
      end
    end
  end

  def test_the_committed_svgs_match_the_script
    Dir.mktmpdir do |out|
      C4::Build.write(out).each do |file|
        committed = File.join(C4_SKILL_ROOT, "references", file.delete_prefix("#{out}/"))

        assert_equal File.read(file), File.read(committed), "#{committed} is stale: run scripts/build.rb"
      end
    end
  end

  def test_every_diagram_reference_links_its_example_and_notation_lists_every_key
    DIAGRAM_TYPES.each do |type|
      reference = File.read(File.join(C4_SKILL_ROOT, "references/#{type}.md"))

      assert_includes reference, "references/examples/#{type}.svg", "#{type}.md does not link its example"
      assert_includes reference, "references/keys/", "#{type}.md lists no keys"
    end
    notation = File.read(File.join(C4_SKILL_ROOT, "references/notation.md"))
    C4::Build::KEYS.each_key { |key| assert_includes notation, "references/keys/#{key}.svg", "notation.md omits #{key}" }
  end
end
