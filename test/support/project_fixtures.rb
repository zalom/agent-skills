require "fileutils"
require "tmpdir"

TESTING_SKILL_ROOT = File.expand_path("../../ruby-testing", __dir__)
WRITING_SKILL_ROOT = File.expand_path("../../ruby-writing", __dir__)
QUALITY_SKILL_ROOT = File.expand_path("../../ruby-quality-checking", __dir__)

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
