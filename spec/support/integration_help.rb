# typed: false
# frozen_string_literal: true

require 'fileutils'

# Helper methods for integration specs.
module IntegrationHelp
  def test_files
    @test_files ||= []
  end

  def cleanup_test_files
    test_files.each do |f|
      FileUtils.rm(f) if File.exist?(f)
    end
  end

  # @param original_path [String]
  # @return [String]
  def make_temp_test_file(original_path)
    file_name = File.basename(original_path)
    relative_tmp_path = File.join(temp_base_dir, file_name)
    tmp_path = File.expand_path(relative_tmp_path, __dir__)

    return tmp_path if test_files.include?(tmp_path)

    FileUtils.cp(original_path, tmp_path)
    test_files << tmp_path

    tmp_path
  end

  def temp_base_dir
    File.join(%w[.. .. tmp])
  end
end
