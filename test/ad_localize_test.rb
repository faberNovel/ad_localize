require "test_helper"
require 'fileutils'
require 'diffy'

class AdLocalizeTest < TestCase
  test 'it has a version number' do
    refute_nil ::AdLocalize::VERSION
  end

  test 'it should export correct ios files' do
  	# Remove exports if needed
  	FileUtils.rm_rf('exports')

		# When
		runner = AdLocalize::Runner.new
		runner.run ["test/reference.csv"]

		# Then
		all_files.each do |file|
			reference_file = "test/exports_reference/#{file}"
			test_file = "exports/#{file}"
			assert(File.exist?(test_file), "File does not exists #{test_file}")
			diff = Diffy::Diff.new(reference_file, test_file, :source => 'files')
			assert_empty(diff.to_s, "File #{file} do not match reference. Diff: \n\n#{diff}\n")
		end

		# Clean up
  	FileUtils.rm_rf('exports')
  end

  private

  def all_files
  	ios_files + android_files + json_files + yml_files
  end

  def ios_files
  	files = ["InfoPlist.strings", "Localizable.strings", "Localizable.stringsdict"]
  	languages
  		.map { |x| "#{x}.lproj" }
  		.product(files)
  		.map { |x| "ios/#{x[0]}/#{x[1]}" }
  end

  def android_files
  	languages
  		.each_with_index
  		.map { |x, i| i == 0 ? "values" : "values-#{x}" }
  		.map { |x| "android/#{x}/strings.xml" }
  end

  def json_files
  	languages.map { |x| "json/#{x}.json" }
  end

  def yml_files
  	languages.map { |x| "yml/#{x}.yml" }
  end

  def languages
  	["fr", "en"]
  end
end
