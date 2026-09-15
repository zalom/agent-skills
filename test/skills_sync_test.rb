require "minitest/autorun"
require_relative "support/project_fixtures"

class SkillsSyncTest < Minitest::Test
  def test_project_profile_copies_are_identical
    testing = File.read(File.join(TESTING_SKILL_ROOT, "scripts/project_profile.rb"))
    quality = File.read(File.join(QUALITY_SKILL_ROOT, "scripts/project_profile.rb"))

    assert_equal quality, testing
  end
end
