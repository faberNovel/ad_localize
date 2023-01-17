require 'test_helper'

module AdLocalize
  module Interactors
    class ProcessExportRequestTest < TestCase
      def setup
        # Remove exports if needed
        FileUtils.rm_rf('exports')
      end

      def teardown
        # Clean up
        FileUtils.rm_rf('exports')
      end

      test 'it should export json file with bad inputs' do
        # Given
        csv_file = "test/fixtures/reference_json_bad_input.csv"
        reference_dir = "test/fixtures/exports_reference_json_bad_input"
        assert(File.exist?(csv_file), "File does not exists #{csv_file}")
        assert(File.exist?(reference_dir), "File does not exists #{reference_dir}")

        # When
        export_request = Requests::ExportRequest.new(csv_paths: [csv_file], platforms: %w(json))
        ProcessExportRequest.new.call(export_request: export_request)

        # Then
        reference_file = "#{reference_dir}/en.json"
        generated_file = "exports/en.json"
        assert(File.exist?(reference_file), "File does not exists #{reference_file}")
        assert(File.exist?(generated_file), "File does not exists #{generated_file}")
        diff = Diffy::Diff.new(reference_file, generated_file, :source => 'files')
        assert_empty(diff.to_s, "File #{generated_file} do not match reference. Diff: \n\n#{diff}\n")
      end

      test 'it should export ios file with duplicated keys' do
        # Given
        csv_file = "test/fixtures/reference_duplicates.csv"
        reference_dir = "test/fixtures/exports_reference_duplicates"
        assert(File.exist?(csv_file), "File does not exists #{csv_file}")
        assert(File.exist?(reference_dir), "File does not exists #{reference_dir}")

        # When
        export_request = Requests::ExportRequest.new(csv_paths: [csv_file], platforms: %w(ios))
        ProcessExportRequest.new.call(export_request: export_request)

        # Then
        ios_files(with_platform_directory: false)
          .reject { |file| file.include? "InfoPlist.strings" }
          .each do |file|
            reference_file = "#{reference_dir}/#{file}"
            generated_file = "exports/#{file}"
            assert(File.exist?(reference_file), "File does not exists #{reference_file}")
            assert(File.exist?(generated_file), "File does not exists #{generated_file}")
            diff = Diffy::Diff.new(reference_file, generated_file, :source => 'files')
            assert_empty(diff.to_s, "File #{generated_file} do not match reference. Diff: \n\n#{diff}\n")
          end
      end

      test 'it should export correct platforms files' do
        # Given
        csv_file = "test/fixtures/reference.csv"
        reference_dir = "test/fixtures/exports_reference"
        assert(File.exist?(csv_file), "File does not exists #{csv_file}")
        assert(File.exist?(reference_dir), "File does not exists #{reference_dir}")

        # When
        export_request = Requests::ExportRequest.new(csv_paths: [csv_file])
        ProcessExportRequest.new.call(export_request: export_request)

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
        csv_file = "test/fixtures/reference.csv"
        assert(File.exist?(csv_file), "File does not exists #{csv_file}")
        platforms = %w(ios)

        # When
        export_request = Requests::ExportRequest.new(csv_paths: [csv_file], platforms: platforms)
        ProcessExportRequest.new.call(export_request: export_request)

        # Then
        ios_files(with_platform_directory: false).each do |file|
          generated_file = "exports/#{file}"
          assert(File.exist?(generated_file), "File does not exists #{generated_file}")
        end
      end

      test 'it should merge multiple input csv files replacing old values' do
        # Given
        csv_files = %w(test/fixtures/reference.csv test/fixtures/reference1.csv test/fixtures/reference2.csv)
        csv_files.each { |file| assert(File.exist?(file), "File does not exists #{file}") }
        reference_dir = "test/fixtures/exports_merge_replace"
        assert(File.exist?(reference_dir), "File does not exists #{reference_dir}")

        # When
        export_request = Requests::ExportRequest.new(csv_paths: csv_files, merge_policy: 'replace')
        ProcessExportRequest.new.call(export_request: export_request)

        # Then
        all_files.each do |file|
          reference_file = "#{reference_dir}/#{file}"
          generated_file = "exports/#{file}"
          assert(File.exist?(generated_file), "File does not exists #{generated_file}")
          diff = Diffy::Diff.new(reference_file, generated_file, :source => 'files')
          assert_empty(diff.to_s, "File #{generated_file} do not match reference. Diff: \n\n#{diff}\n")
        end
      end

      test 'it should merge multiple input csv files keeping old values' do
        # Given
        csv_files = %w(test/fixtures/reference.csv test/fixtures/reference1.csv test/fixtures/reference2.csv)
        csv_files.each { |file| assert(File.exist?(file), "File does not exists #{file}") }
        reference_dir = "test/fixtures/exports_merge_keep"
        assert(File.exist?(reference_dir), "File does not exists #{reference_dir}")

        # When
        export_request = Requests::ExportRequest.new(csv_paths: csv_files, merge_policy: 'keep')
        ProcessExportRequest.new.call(export_request: export_request)

        # Then
        all_files.each do |file|
          reference_file = "#{reference_dir}/#{file}"
          generated_file = "exports/#{file}"
          assert(File.exist?(generated_file), "File does not exists #{generated_file}")
          diff = Diffy::Diff.new(reference_file, generated_file, :source => 'files')
          assert_empty(diff.to_s, "File #{generated_file} do not match reference. Diff: \n\n#{diff}\n")
        end
      end

      test 'it should only export non-empty values' do
        # Given
        csv_files = %w(test/fixtures/reference_empty_values.csv)
        csv_files.each { |file| assert(File.exist?(file), "File does not exists #{file}") }
        reference_dir = "test/fixtures/exports_non_empty"
        assert(File.exist?(reference_dir), "File does not exists #{reference_dir}")

        # When
        export_request = Requests::ExportRequest.new(csv_paths: csv_files, bypass_empty_values: true)
        ProcessExportRequest.new.call(export_request: export_request)

        # Then
        ios_files(files: ["Localizable.strings", "Localizable.stringsdict"]).each do |file|
          reference_file = "#{reference_dir}/#{file}"
          generated_file = "exports/#{file}"
          assert(File.exist?(generated_file), "File does not exists #{generated_file}")
          diff = Diffy::Diff.new(reference_file, generated_file, :source => 'files')
          assert_empty(diff.to_s, "File #{generated_file} do not match reference. Diff: \n\n#{diff}\n")
        end
      end

      private

      def all_files(languages: DEFAULT_LANGUAGES)
        ios_files(languages: languages) +
          android_files(languages: languages) +
          json_files(languages: languages) +
          yml_files(languages: languages) +
          properties_files(languages: languages)
      end

      def ios_files(with_platform_directory: true, languages: DEFAULT_LANGUAGES, files: DEFAULT_IOS_FILES)
        languages
          .map { |language| "#{language}.lproj" }
          .product(files)
          .map { |language_folder, file| "#{language_folder}/#{file}" }
          .map { |file| with_platform_directory ? "ios/#{file}" : file }
      end

      def android_files(languages: DEFAULT_LANGUAGES)
        languages
          .each_with_index
          .map { |language, i| i == 0 ? "values" : "values-#{language}" }
          .map { |language_folder| "android/#{language_folder}/strings.xml" }
      end

      def json_files(languages: DEFAULT_LANGUAGES)
        languages.map { |language| "json/#{language}.json" }
      end

      def yml_files(languages: DEFAULT_LANGUAGES)
        languages.map { |language| "yml/#{language}.yml" }
      end

      def properties_files(languages: DEFAULT_LANGUAGES)
        languages.map { |language| "properties/#{language}.properties" }
      end
    end
  end
end
