if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    enable_coverage :branch
    skip "/spec/"
    cover "{app,lib,tools}/**/*.rb"
  end
end

