require 'test_helper'

module AdLocalize
  module Requests
    class ExportRequestTest < TestCase
      test 'should get locales' do
        request = ExportRequest.new(locales: "")
        assert_empty request.locales

        request = ExportRequest.new(locales: %w(fr en))
        assert_equal %w(fr en), request.locales

        request = ExportRequest.new(locales: 'fr')
        assert_equal %w(fr), request.locales

        request = ExportRequest.new(locales: nil)
        assert_equal [], request.locales
      end

      test 'should get platforms' do
        request = ExportRequest.new(platforms: "")
        assert_equal ExportRequest::SUPPORTED_PLATFORMS, request.platforms

        request = ExportRequest.new(platforms: %w(ios android))
        assert_equal %w(ios android), request.platforms

        request = ExportRequest.new(platforms: 'json')
        assert_equal %w(json), request.platforms

        request = ExportRequest.new(platforms: nil)
        assert_equal ExportRequest::SUPPORTED_PLATFORMS, request.platforms
      end

      test 'should get g_spreadsheet_options' do
        request = ExportRequest.new(g_spreadsheet_options: nil)
        assert_nil request.g_spreadsheet_options

        g_spreadsheet_options = GSpreadsheetOptions.new
        request = ExportRequest.new(g_spreadsheet_options: g_spreadsheet_options)
        assert_equal g_spreadsheet_options, request.g_spreadsheet_options
      end

      test 'should get output path' do
        request = ExportRequest.new(output_path: "")
        assert_equal ExportRequest::DEFAULT_EXPORT_FOLDER, request.output_path.to_path

        request = ExportRequest.new(output_path: 'foo')
        assert_equal 'foo', request.output_path.to_path

        request = ExportRequest.new(output_path: nil)
        assert_equal ExportRequest::DEFAULT_EXPORT_FOLDER, request.output_path.to_path
      end

      test 'should get verbose' do
        request = ExportRequest.new(verbose: nil)
        refute request.verbose

        request = ExportRequest.new(verbose: "")
        refute request.verbose

        request = ExportRequest.new(verbose: true)
        assert request.verbose

        request = ExportRequest.new(verbose: false)
        refute request.verbose
      end

      test 'should get merge policy' do
        request = ExportRequest.new(merge_policy: nil)
        assert_nil request.merge_policy

        request = ExportRequest.new(merge_policy: "")
        assert_nil request.merge_policy

        request = ExportRequest.new(merge_policy: 'replace')
        assert_nil request.merge_policy

        request = ExportRequest.new(merge_policy: 'keep')
        assert_nil request.merge_policy

        request = ExportRequest.new(merge_policy: 'foo')
        assert_nil request.merge_policy
      end

      test 'should detect if request has csv files' do
        request = ExportRequest.new
        refute request.has_csv_files?

        request = ExportRequest.new(csv_paths: %w(foo))
        refute request.has_csv_files?

        request = ExportRequest.new(csv_paths: [__dir__ + "/../fixtures/reference.csv"])
        assert request.has_csv_files?
      end

      test 'should detect if request has csv google spreadsheet options' do
        request = ExportRequest.new(g_spreadsheet_options: nil)
        refute request.has_g_spreadsheet_options?

        g_spreadsheet_options = GSpreadsheetOptions.new
        request = ExportRequest.new(g_spreadsheet_options: g_spreadsheet_options)
        assert request.has_g_spreadsheet_options?
      end

      test 'should detect if request has multiple platforms' do
        request = ExportRequest.new(platforms: "")
        assert request.multiple_platforms?

        request = ExportRequest.new(platforms: %w(ios android))
        assert request.multiple_platforms?

        request = ExportRequest.new(platforms: 'json')
        refute request.multiple_platforms?

        request = ExportRequest.new(platforms: nil)
        assert request.multiple_platforms?
      end

      test 'should detect if request is valid with one csv' do
        request = ExportRequest.new
        refute request.valid?

        request = ExportRequest.new(csv_paths: %w(foo))
        refute request.valid?

        request = ExportRequest.new(csv_paths: [__dir__ + "/../fixtures/reference.csv"])
        assert request.valid?

        request = ExportRequest.new(csv_paths: [__dir__ + "/../fixtures/reference.csv"], platforms: %w(foo))
        refute request.valid?
      end

      test 'should detect if request is valid with multiple csv' do
        request = ExportRequest.new(csv_paths: [__dir__ + "/../fixtures/reference.csv"] * 2)
        assert request.valid?
        assert_equal MergePolicy::DEFAULT_POLICY, request.merge_policy.policy

        request = ExportRequest.new(csv_paths: [__dir__ + "/../fixtures/reference.csv"] * 2, merge_policy: 'keep')
        assert request.valid?
        assert_equal 'keep', request.merge_policy.policy

        request = ExportRequest.new(csv_paths: [__dir__ + "/../fixtures/reference.csv"] * 2, merge_policy: 'replace')
        assert request.valid?
        assert_equal 'replace', request.merge_policy.policy

        request = ExportRequest.new(csv_paths: [__dir__ + "/../fixtures/reference.csv"] * 2, merge_policy: 'foo')
        refute request.valid?
        assert_equal 'foo', request.merge_policy.policy

        request = ExportRequest.new(
          csv_paths: [__dir__ + "/../fixtures/reference.csv"] * 2,
          merge_policy: 'keep',
          platforms: %w(foo bar)
        )
        refute request.valid?
      end

      test 'should detect if request is valid with one sheet' do
        g_spreadsheet_options = GSpreadsheetOptions.new(spreadsheet_id: 'spreadsheet_id')
        request = ExportRequest.new(g_spreadsheet_options: g_spreadsheet_options)
        assert request.valid?

        g_spreadsheet_options = GSpreadsheetOptions.new(spreadsheet_id: 'spreadsheet_id', sheet_ids: %w(one))
        request = ExportRequest.new(g_spreadsheet_options: g_spreadsheet_options)
        assert request.valid?
      end

      test 'should detect if request is valid with multiple sheets' do
        g_spreadsheet_options = GSpreadsheetOptions.new(spreadsheet_id: 'spreadsheet_id', sheet_ids: %w(one two))
        request = ExportRequest.new(g_spreadsheet_options: g_spreadsheet_options)
        assert request.valid?
        assert_equal MergePolicy::DEFAULT_POLICY, request.merge_policy.policy

        g_spreadsheet_options = GSpreadsheetOptions.new(spreadsheet_id: 'spreadsheet_id', sheet_ids: %w(one two))
        request = ExportRequest.new(g_spreadsheet_options: g_spreadsheet_options, merge_policy: 'keep')
        assert request.valid?
        assert_equal 'keep', request.merge_policy.policy

        g_spreadsheet_options = GSpreadsheetOptions.new(spreadsheet_id: 'spreadsheet_id', export_all: true)
        request = ExportRequest.new(g_spreadsheet_options: g_spreadsheet_options, merge_policy: 'replace')
        refute request.valid?
        assert_equal 'replace', request.merge_policy.policy

        g_spreadsheet_options = GSpreadsheetOptions.new(
          spreadsheet_id: 'spreadsheet_id',
          export_all: true,
          service_account_config: "{ \"a\": \"b\"}"
        )
        request = ExportRequest.new(g_spreadsheet_options: g_spreadsheet_options, merge_policy: 'keep')
        assert request.valid?
      end

      test 'should detect if request is verbose' do
        request = ExportRequest.new(verbose: nil)
        refute request.verbose?

        request = ExportRequest.new(verbose: "")
        refute request.verbose?

        request = ExportRequest.new(verbose: true)
        assert request.verbose?

        request = ExportRequest.new(verbose: false)
        refute request.verbose?
      end

      test 'should detect if request has only non empty values' do
        request = ExportRequest.new(non_empty_values: true)
        assert request.non_empty_values?

        request = ExportRequest.new(non_empty_values: false)
        refute request.non_empty_values?

        request = ExportRequest.new(non_empty_values: nil)
        refute request.non_empty_values?

        request = ExportRequest.new(non_empty_values: "")
        refute request.non_empty_values?
      end
    end
  end
end