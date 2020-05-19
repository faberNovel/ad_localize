require "test_helper"
require 'fileutils'
require 'diffy'

class AdLocalizeTest < TestCase

  def setup
    # Remove exports if needed
    FileUtils.rm_rf('exports')
  end

  def teardown
    # Clean up
    FileUtils.rm_rf('exports')
  end

  test 'it has a version number' do
    refute_nil ::AdLocalize::VERSION
  end

  test 'it should export correct platforms files' do
    # Given
    csv_file = "test/reference.csv"
    reference_dir = "test/exports_reference"
    assert(File.exist?(csv_file), "File does not exists #{csv_file}")
    assert(File.exist?(reference_dir), "File does not exists #{reference_dir}")

    # When
    runner = AdLocalize::Runner.new
    runner.run [csv_file]

    # Then
    all_files.each do |file|
      reference_file = "#{reference_dir}/#{file}"
      generated_file = "exports/#{file}"
      assert(File.exist?(generated_file), "File does not exists #{generated_file}")
      diff = Diffy::Diff.new(reference_file, generated_file, :source => 'files')
      assert_empty(diff.to_s, "File #{generated_file} do not match reference. Diff: \n\n#{diff}\n")
    end
  end

  test 'it should not create intermediate platform directory' do
    # Given
    csv_file = "test/reference.csv"
    assert(File.exist?(csv_file), "File does not exists #{csv_file}")
    options = { only: ["ios"] }

    # When
    runner = AdLocalize::Runner.new
    runner.options = options
    runner.run [csv_file]

    # Then
    ios_files(with_platform_directory: false).each do |file|
      generated_file = "exports/#{file}"
      assert(File.exist?(generated_file), "File does not exists #{generated_file}")
    end
  end

  private

  def all_files
    ios_files + android_files + json_files + yml_files + properties_files
  end

  def ios_files(with_platform_directory: true)
    files = ["InfoPlist.strings", "Localizable.strings", "Localizable.stringsdict"]
    languages
      .map { |language| "#{language}.lproj" }
      .product(files)
      .map { |language_folder, file| "#{language_folder}/#{file}" }
      .map { |file| with_platform_directory ? "ios/#{file}" : file }
  end

  def android_files
    languages
      .each_with_index
      .map { |language, i| i == 0 ? "values" : "values-#{language}" }
      .map { |language_folder| "android/#{language_folder}/strings.xml" }
  end

  def json_files
    languages.map { |language| "json/#{language}.json" }
  end

  def yml_files
    languages.map { |language| "yml/#{language}.yml" }
  end


  def properties_files
    languages.map { |language| "properties/#{language}.properties" }
  end

  def languages
    ["fr", "en"]
  end
end
