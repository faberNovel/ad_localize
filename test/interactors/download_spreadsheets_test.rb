# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Interactors
    class DownloadSpreadsheetsTest < TestCase
      def teardown
        @downloaded_csvs&.each do |file|
          file.close
          file.unlink
        end
      end

      test 'does not convert office paths without excel file option' do
        export_request = Requests::ExportRequest.new
        excel_path = 'test/fixtures/reference.xlsx'
        export_request.csv_paths = [excel_path]

        @downloaded_csvs = DownloadSpreadsheets.new.call(export_request: export_request)

        assert_equal [Pathname.new(excel_path)], export_request.csv_paths
        assert_empty @downloaded_csvs
      end

      test 'converts excel file option to csv' do
        export_request = Requests::ExportRequest.new
        excel_path = 'test/fixtures/reference.xlsx'
        export_request.excel_file = excel_path

        @downloaded_csvs = DownloadSpreadsheets.new.call(export_request: export_request)

        assert_equal 1, @downloaded_csvs.size
        assert File.exist?(@downloaded_csvs.first.path)
      end
    end
  end
end
