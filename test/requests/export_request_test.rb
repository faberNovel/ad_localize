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
      end

      # test 'should get platforms' do
      #   request = ExportRequest.new(platforms: "")
      #   assert_equal Entities::Platform::SUPPORTED_PLATFORMS, request.platforms

      #   request = ExportRequest.new(platforms: %w(ios android))
      #   assert_equal %w(ios android), request.platforms

      #   request = ExportRequest.new(platforms: 'json')
      #   assert_equal %w(json), request.platforms

      #   request = ExportRequest.new(platforms: nil)
      #   assert_empty request.platforms

      #   request = ExportRequest.new(platforms: %w(foo bar ios))
      #   assert_equal %w(ios), request.platforms
      # end

      test 'should get output path' do
        request = ExportRequest.new(output_path: '')
        assert_equal ExportRequest::DEFAULTS[:output_path], request.output_path

        request = ExportRequest.new(output_path: 'foo')
        assert_equal 'foo', request.output_path

        request = ExportRequest.new(output_path: nil)
        assert_equal ExportRequest::DEFAULTS[:output_path], request.output_path
      end

      # test 'should get verbose' do
      #   request = ExportRequest.new(verbose: nil)
      #   refute request.verbose

      #   request = ExportRequest.new(verbose: "")
      #   refute request.verbose

      #   request = ExportRequest.new(verbose: true)
      #   assert request.verbose

      #   request = ExportRequest.new(verbose: false)
      #   refute request.verbose
      # end

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

      # test 'should detect if request is valid with one csv' do
      #   request = ExportRequest.new
      #   assert_not request.valid?

      #   request = ExportRequest.new(csv_paths: %w(foo))
      #   refute request.valid?

      #   request = ExportRequest.new(csv_paths: [__dir__ + "/../fixtures/reference.csv"])
      #   assert request.valid?

      #   request = ExportRequest.new(csv_paths: [__dir__ + "/../fixtures/reference.csv"], platforms: %w(foo))
      #   refute request.valid?
      # end

      # test 'should detect if request is valid with one sheet' do
      #   request = ExportRequest.new(spreadsheet_id: 'spreadsheet_id')
      #   assert request.valid?

      #   request = ExportRequest.new(spreadsheet_id: 'spreadsheet_id', sheet_ids: %w(one))
      #   assert request.valid?
      # end

      # test 'should detect if request is verbose' do
      #   request = ExportRequest.new(verbose: nil)
      #   refute request.verbose

      #   request = ExportRequest.new(verbose: "")
      #   refute request.verbose

      #   request = ExportRequest.new(verbose: true)
      #   assert request.verbose

      #   request = ExportRequest.new(verbose: false)
      #   refute request.verbose
      # end

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
    end
  end
end
