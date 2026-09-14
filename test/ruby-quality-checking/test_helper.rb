require "minitest/autorun"
require "fileutils"
require "stringio"
require "tmpdir"
require "yaml"

SKILL_ROOT = File.expand_path("../../ruby-quality-checking", __dir__)

load File.join(SKILL_ROOT, "scripts/setup-project")
load File.join(SKILL_ROOT, "assets/bin/verify-change")

module ProjectFixtures
  def in_project(files)
    Dir.mktmpdir do |root|
      files.each do |relative, content|
        FileUtils.mkdir_p(File.dirname(File.join(root, relative)))
        File.write(File.join(root, relative), content)
      end
      yield root
    end
  end

  def read(root, relative)
    File.read(File.join(root, relative))
  end
end
