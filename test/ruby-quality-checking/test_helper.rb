require "minitest/autorun"
require "stringio"
require "yaml"
require_relative "../support/project_fixtures"

load File.join(QUALITY_SKILL_ROOT, "scripts/setup-project")
load File.join(QUALITY_SKILL_ROOT, "assets/bin/verify-change")
