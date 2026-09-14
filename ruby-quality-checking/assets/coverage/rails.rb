if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start "rails" do
    enable_coverage :branch
    cover "{app,lib,tools}/**/*.rb"
  end
end

