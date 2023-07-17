# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Requests
    class ExportRequestTest < TestCase
      test 'should get locales' do
        request = ExportRequest.new(locales: '')
        assert_empty request.locales

        request = ExportRequest.new(locales: %w[fr en])
        assert_equal %w[fr en], request.locales

        request = ExportRequest.new(locales: nil)
        assert_empty request.locales

        request = ExportRequest.new(locales: [])
        assert_empty request.locales
      end

      test 'should detect if request bypasses empty values' do
        request = ExportRequest.new(bypass_empty_values: true)
        assert request.bypass_empty_values

        request = ExportRequest.new(bypass_empty_values: false)
        assert_not request.bypass_empty_values

        request = ExportRequest.new(bypass_empty_values: nil)
        assert_not request.bypass_empty_values

        request = ExportRequest.new(bypass_empty_values: '')
        assert_not request.bypass_empty_values
      end

      test 'should get csv paths' do
        request = ExportRequest.new(csv_paths: [])
        assert_empty request.csv_paths

        request = ExportRequest.new(csv_paths: %w[csv_1 csv_2])
        assert_equal [Pathname.new('csv_1'), Pathname.new('csv_2')], request.csv_paths

        request = ExportRequest.new(csv_paths: nil)
        assert_empty request.csv_paths
      end

      test 'should get merge policy' do
        request = ExportRequest.new(merge_policy: nil)
        assert_equal 'keep', request.merge_policy

        request = ExportRequest.new(merge_policy: '')
        assert_equal 'keep', request.merge_policy

        request = ExportRequest.new(merge_policy: 'replace')
        assert_equal 'replace', request.merge_policy

        request = ExportRequest.new(merge_policy: 'keep')
        assert_equal 'keep', request.merge_policy

        request = ExportRequest.new(merge_policy: 'foo')
        assert_equal 'foo', request.merge_policy
      end

      test 'should get output path' do
        request = ExportRequest.new(output_path: '')
        assert_equal Pathname.new(ExportRequest::DEFAULTS[:output_path]), request.output_path

        request = ExportRequest.new(output_path: 'foo')
        assert_equal Pathname.new('foo'), request.output_path

        request = ExportRequest.new(output_path: nil)
        assert_equal Pathname.new(ExportRequest::DEFAULTS[:output_path]), request.output_path
      end

      test 'should get platforms' do
        request = ExportRequest.new(platforms: '')
        assert_equal Entities::Platform::SUPPORTED_PLATFORMS, request.platforms

        request = ExportRequest.new(platforms: %w[ios android])
        assert_equal %w[ios android], request.platforms

        request = ExportRequest.new(platforms: 'json')
        assert_equal %w[json], request.platforms

        request = ExportRequest.new(platforms: nil)
        assert_equal Entities::Platform::SUPPORTED_PLATFORMS, request.platforms

        request = ExportRequest.new(platforms: %w[foo bar ios])
        assert_equal %w[ios], request.platforms
      end

      test 'should get spreadsheet id' do
        request = ExportRequest.new(spreadsheet_id: '')
        assert_nil request.spreadsheet_id

        request = ExportRequest.new(spreadsheet_id: nil)
        assert_nil request.spreadsheet_id

        request = ExportRequest.new(spreadsheet_id: 'spreadsheet_id')
        assert_equal 'spreadsheet_id', request.spreadsheet_id
      end

      test 'should get sheet ids' do
        request = ExportRequest.new(sheet_ids: '')
        assert_equal ExportRequest::DEFAULTS[:sheet_ids], request.sheet_ids

        request = ExportRequest.new(sheet_ids: nil)
        assert_equal ExportRequest::DEFAULTS[:sheet_ids], request.sheet_ids

        request = ExportRequest.new(sheet_ids: [])
        assert_equal ExportRequest::DEFAULTS[:sheet_ids], request.sheet_ids

        request = ExportRequest.new(sheet_ids: %w[sheet_1 sheet_2])
        assert_equal %w[sheet_1 sheet_2], request.sheet_ids
      end

      test 'should get export all' do
        request = ExportRequest.new(export_all: nil)
        assert_not request.export_all

        request = ExportRequest.new(export_all: '')
        assert_not request.export_all

        request = ExportRequest.new(export_all: true)
        assert request.export_all

        request = ExportRequest.new(export_all: false)
        assert_not request.export_all
      end

      test 'should get verbose' do
        request = ExportRequest.new(verbose: nil)
        assert_not request.verbose

        request = ExportRequest.new(verbose: '')
        assert_not request.verbose

        request = ExportRequest.new(verbose: true)
        assert request.verbose

        request = ExportRequest.new(verbose: false)
        assert_not request.verbose
      end

      test 'should get downloaded csvs' do
        request = ExportRequest.new(downloaded_csvs: nil)
        assert_empty request.downloaded_csvs

        request = ExportRequest.new(downloaded_csvs: '')
        assert_empty request.downloaded_csvs

        request = ExportRequest.new(downloaded_csvs: [])
        assert_empty request.downloaded_csvs

        request = ExportRequest.new(downloaded_csvs: %w[csv_1 csv_2])
        assert_equal %w[csv_1 csv_2], request.downloaded_csvs
      end
    end
  end
end
