# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  class CLITest < TestCase
    def setup
      FileUtils.rm_rf('exports')
    end

    def teardown
      FileUtils.rm_rf('exports')
    end

    test 'exports wording from excel file' do
      CLI.start(args: %w[-f test/fixtures/reference.xlsx])

      all_files.each do |file|
        reference_file = "test/fixtures/exports_reference/#{file}"
        generated_file = "exports/#{file}"
        assert(File.exist?(generated_file), "File does not exists #{generated_file}")
        diff = Diffy::Diff.new(reference_file, generated_file, source: 'files')
        assert_empty(diff.to_s, "File #{generated_file} do not match reference. Diff: \n\n#{diff}\n")
      end
    end

    test 'exports wording from named excel sheet' do
      CLI.start(args: %w[-f test/fixtures/reference_excel_sheets.xlsx -s Wordings -o json])

      reference_file = 'test/fixtures/exports_reference/json/en.json'
      generated_file = 'exports/en.json'
      assert(File.exist?(generated_file), "File does not exists #{generated_file}")
      diff = Diffy::Diff.new(reference_file, generated_file, source: 'files')
      assert_empty(diff.to_s, "File #{generated_file} do not match reference. Diff: \n\n#{diff}\n")
    end
  end
end
