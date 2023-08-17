# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Requests
    class ExportRequestTest < TestCase
      setup do
        @request = ExportRequest.new
      end

      test 'should get locales' do
        assert_no_changes -> { @request.locales } do
          @request.locales = ''
        end

        @request.locales = %w[fr en]
        assert_equal %w[fr en], @request.locales

        assert_no_changes -> { @request.locales } do
          @request.locales = nil
        end

        @request.locales = []
        assert_empty @request.locales
      end

      test 'should detect if request bypasses empty values' do
        @request.bypass_empty_values = true
        assert @request.bypass_empty_values

        @request.bypass_empty_values = false
        assert_not @request.bypass_empty_values

        @request.bypass_empty_values = nil
        assert_not @request.bypass_empty_values

        @request.bypass_empty_values = ''
        assert_not @request.bypass_empty_values
      end

      test 'should detect if request auto escape empty values' do
        @request.auto_escape_percent = true
        assert @request.auto_escape_percent

        @request.auto_escape_percent = false
        assert_not @request.auto_escape_percent

        @request.auto_escape_percent = nil
        assert_not @request.auto_escape_percent

        @request.auto_escape_percent = ''
        assert_not @request.auto_escape_percent
      end

      test 'should get csv paths' do
        @request.csv_paths = []
        assert_empty @request.csv_paths

        @request.csv_paths = %w[csv_1 csv_2]
        assert_equal [Pathname.new('csv_1'), Pathname.new('csv_2')], @request.csv_paths

        assert_no_changes -> { @request.csv_paths } do
          @request.csv_paths = nil
        end
      end

      test 'should get merge policy' do
        assert_no_changes -> { @request.merge_policy } do
          @request.merge_policy = nil
        end

        assert_no_changes -> { @request.merge_policy } do
          @request.merge_policy = ''
        end

        @request.merge_policy = 'replace'
        assert_equal 'replace', @request.merge_policy

        @request.merge_policy = 'keep'
        assert_equal 'keep', @request.merge_policy

        @request.merge_policy = 'foo'
        assert_equal 'foo', @request.merge_policy
      end

      test 'should get output path' do
        assert_no_changes -> { @request.output_path } do
          @request.output_path = ''
        end

        @request.output_path = 'foo'
        assert_equal Pathname.new('foo'), @request.output_path

        assert_no_changes -> { @request.output_path } do
          @request.output_path = nil
        end
      end

      test 'should get platforms' do
        assert_no_changes -> { @request.platforms } do
          @request.platforms = ''
        end

        @request.platforms = %w[ios android]
        assert_equal %w[ios android], @request.platforms

        assert_no_changes -> { @request.platforms } do
          @request.platforms = 'json'
        end

        assert_no_changes -> { @request.platforms } do
          @request.platforms = nil
        end

        @request.platforms = %w[foo bar ios]
        assert_equal %w[ios], @request.platforms
      end

      test 'should get spreadsheet id' do
        assert_no_changes -> { @request.spreadsheet_id } do
          @request.spreadsheet_id = ''
        end

        assert_no_changes -> { @request.spreadsheet_id } do
          @request.spreadsheet_id = nil
        end

        @request.spreadsheet_id = 'spreadsheet_id'
        assert_equal 'spreadsheet_id', @request.spreadsheet_id
      end

      test 'should get sheet ids' do
        @request.sheet_ids = ''
        assert_equal ExportRequest::DEFAULTS[:sheet_ids], @request.sheet_ids

        @request.sheet_ids = nil
        assert_equal ExportRequest::DEFAULTS[:sheet_ids], @request.sheet_ids

        @request.sheet_ids = []
        assert_empty @request.sheet_ids

        @request.sheet_ids = %w[sheet_1 sheet_2]
        assert_equal %w[sheet_1 sheet_2], @request.sheet_ids
      end

      test 'should get export all' do
        @request.export_all = nil
        assert_not @request.export_all

        @request.export_all = ''
        assert_not @request.export_all

        @request.export_all = true
        assert @request.export_all

        @request.export_all = false
        assert_not @request.export_all
      end

      test 'should get verbose' do
        @request.verbose = nil
        assert_not @request.verbose

        @request.verbose = ''
        assert_not @request.verbose

        @request.verbose = true
        assert @request.verbose

        @request.verbose = false
        assert_not @request.verbose
      end

      test 'should get downloaded csvs' do
        @request.downloaded_csvs = nil
        assert_empty @request.downloaded_csvs

        @request.downloaded_csvs = ''
        assert_empty @request.downloaded_csvs

        @request.downloaded_csvs = []
        assert_empty @request.downloaded_csvs

        @request.downloaded_csvs = %w[csv_1 csv_2]
        assert_equal %w[csv_1 csv_2], @request.downloaded_csvs
      end
    end
  end
end
