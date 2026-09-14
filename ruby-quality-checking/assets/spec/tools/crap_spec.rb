require_relative "../../tools/crap"
require "stringio"
require "tmpdir"
require "fileutils"

RSpec.describe Crap do
  let(:source) do
    <<~RUBY_SOURCE
      module Shop
        class Order
          def plain
            1
          end

          def branchy(a, b)
            return 0 if a.nil?
            if a && b
              1
            elsif a || b
              2
            else
              a&.size
            end
          end

          def self.build(kind)
            case kind
            when :a then 1
            when :b then 2
            end
          end
        end
      end
    RUBY_SOURCE
  end
  let(:found) { described_class.methods_in_source(source, "lib/shop/order.rb") }
  let(:method_lines) { { first_line: 3, last_line: 5 } }

  def in_project_with_order(source)
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "lib/shop"))
      File.write(File.join(root, "lib/shop/order.rb"), source)
      yield root
    end
  end

  it "names methods with their namespace" do
    expect(found.map { _1[:name] }).to eq(["Shop::Order#plain", "Shop::Order#branchy", "Shop::Order.build"])
  end

  it "counts cyclomatic complexity" do
    expect(found.map { _1[:complexity] }).to eq([1, 7, 3])
  end

  it "records method line ranges" do
    expect(found.map { [_1[:first_line], _1[:last_line]] }).to eq([[3, 5], [7, 16], [18, 23]])
  end

  it "matches the crap4j formula", :aggregate_failures do
    expect(described_class.formula(6, 1.0)).to eq(6.0)
    expect(described_class.formula(6, 0.0)).to eq(42.0)
    expect(described_class.formula(6, 0.5)).to eq(10.5)
  end

  it "ignores the def and end lines when measuring method coverage", :aggregate_failures do
    expect(described_class.method_coverage(method_lines, [nil, nil, 1, 0, nil])).to eq(0.0)
    expect(described_class.method_coverage(method_lines, [nil, nil, 1, 1, nil])).to eq(1.0)
  end

  it "counts a method without coverage data as uncovered" do
    expect(described_class.method_coverage(method_lines, nil)).to eq(0.0)
  end

  it "merges runs by taking the highest hit count" do
    resultset = { "a" => { "coverage" => { "/x.rb" => { "lines" => [nil, 0, 2] } } },
                  "b" => { "coverage" => { "/x.rb" => { "lines" => [nil, 3, 0] } } } }.to_json

    expect(described_class.line_coverage(resultset)).to eq("/x.rb" => [nil, 3, 2])
  end

  it "reads changed lines from a zero context diff" do
    diff = <<~DIFF
      +++ b/lib/shop/order.rb
      @@ -7,0 +8,3 @@ class Order
      @@ -20 +23 @@ def self.build
      +++ b/lib/shop/cart.rb
      @@ -4,2 +4,0 @@
    DIFF

    expect(described_class.changed_lines(diff)).to eq("lib/shop/order.rb" => [8, 9, 10, 23], "lib/shop/cart.rb" => [4])
  end

  it "treats a method as touched when a changed line falls inside it", :aggregate_failures do
    changed = { "lib/shop/order.rb" => [9] }

    expect(described_class.touched?({ file: "lib/shop/order.rb", first_line: 7, last_line: 16 }, changed)).to be(true)
    expect(described_class.touched?({ file: "lib/shop/order.rb", first_line: 3, last_line: 5 }, changed)).to be(false)
  end

  it "reports methods and fails above the threshold", :aggregate_failures do
    in_project_with_order(source) do |root|
      out = StringIO.new
      status = Crap::CLI.new(["--threshold", "30", "lib/shop/order.rb"], root: root, out: out).run

      expect(status).to eq(1)
      expect(out.string).to include("56.0    7          0%        Shop::Order#branchy")
      expect(out.string).to include("3 methods, 1 above CRAP 30")
    end
  end

  it "scores only touched methods with --since", :aggregate_failures do
    in_project_with_order(source) do |root|
      out = StringIO.new
      git = ->(*) { "+++ b/lib/shop/order.rb\n@@ -3 +3 @@\n" }
      status = Crap::CLI.new(["--since", "main", "lib/shop/order.rb"], root: root, out: out, git: git).run

      expect(status).to eq(0)
      expect(out.string).to include("1 methods, 0 above CRAP 30")
    end
  end

  it "prints the usage with --help", :aggregate_failures do
    out = StringIO.new

    expect(Crap::CLI.new(["--help"], root: Dir.pwd, out: out).run).to eq(0)
    expect(out.string).to include("Exit codes: 0 no method above the threshold")
  end

  it "rejects an unknown option with the usage", :aggregate_failures do
    out = StringIO.new

    expect(Crap::CLI.new(["--bogus"], root: Dir.pwd, out: out).run).to eq(2)
    expect(out.string).to include("Usage: bin/crap")
  end

  it "rejects an option missing its value at the end of the arguments", :aggregate_failures do
    out = StringIO.new

    expect(Crap::CLI.new(["--threshold"], root: Dir.pwd, out: out).run).to eq(2)
    expect(out.string).to include("Usage: bin/crap")
  end

  it "rejects an option missing its value before another option", :aggregate_failures do
    out = StringIO.new

    expect(Crap::CLI.new(["--since", "--coverage", "coverage/.resultset.json"], root: Dir.pwd, out: out).run).to eq(2)
    expect(out.string).to include("Usage: bin/crap")
  end
end
