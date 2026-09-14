# Reads a project's test and quality tooling from its files. Runs no commands.
# Kept byte-identical between ruby-testing/scripts/project_profile.rb and
# ruby-quality-checking/scripts/project_profile.rb; test/skills_sync_test.rb enforces it.
class ProjectProfile
  RSPEC_DEPENDENCY = /^  rspec(-core|-rails)?(\s|!|$)/

  Missing = Struct.new(:goal, :why, :tool, keyword_init: true)

  def initialize(root)
    @root = root
  end

  def ruby_version
    raise NotImplementedError
  end

  def rails?
    raise NotImplementedError
  end

  def gemfile?
    raise NotImplementedError
  end

  def frameworks
    raise NotImplementedError
  end

  def primary_framework
    raise NotImplementedError
  end

  def minitest_version
    raise NotImplementedError
  end

  def simplecov_version
    raise NotImplementedError
  end

  def test_data
    raise NotImplementedError
  end

  def mocking
    raise NotImplementedError
  end

  def coverage
    raise NotImplementedError
  end

  def mutation_tool
    raise NotImplementedError
  end

  def crap_configured?
    raise NotImplementedError
  end

  def style_guide
    raise NotImplementedError
  end

  def ci
    raise NotImplementedError
  end

  def database_adapter
    raise NotImplementedError
  end

  def compose_file?
    raise NotImplementedError
  end

  def missing
    raise NotImplementedError
  end

  def to_h
    raise NotImplementedError
  end
end
