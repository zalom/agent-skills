require "minitest/autorun"
require "open3"
require_relative "../support/project_fixtures"

# ProjectProfile is tested in-process from the copy setup-project loads, so
# a project_profile.rb required by scripts/setup-project (through the
# ruby-quality-checking test helper) is never defined twice in one process.
require File.join(QUALITY_SKILL_ROOT, "scripts/project_profile")

DETECT_TOOLS = File.join(TESTING_SKILL_ROOT, "scripts/detect-tools")
