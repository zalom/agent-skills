if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    enable_coverage :branch
    skip "/test/"
    cover "{app,lib,tools}/**/*.rb"
  end
end

require "minitest/autorun"
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift File.expand_path("../tools", __dir__)
