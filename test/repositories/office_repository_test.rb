# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Repositories
    class OfficeRepositoryTest < TestCase
      def setup
        @repository = OfficeRepository.new
        @created_files = []
      end

      def teardown
        @created_files.each do |file|
          file.close
          file.unlink
        end
      end

      test 'detects excel sources' do
        assert @repository.office_source?(path: Pathname.new('test/fixtures/reference.xlsx'))
        assert @repository.office_source?(path: Pathname.new('https://example.com/reference.xlsx?token=abc'))
        assert_not @repository.office_source?(path: Pathname.new('test/fixtures/reference.csv'))
      end

      test 'converts local excel file to csv' do
        @created_files = @repository.convert_to_csvs(
          paths: [Pathname.new('test/fixtures/reference_whitespace_stripping.xlsx')],
          sheet_ids: Requests::ExportRequest::DEFAULTS[:sheet_ids]
        )

        assert_equal 1, @created_files.size
        wording = Parsers::CSVParser.new.call(csv_path: @created_files.first.path, export_request: Requests::ExportRequest.new)

        assert_equal 'before', wording['en'].singulars['before'].value
      end

      test 'converts selected excel sheets to csv' do
        @created_files = @repository.convert_to_csvs(
          paths: [Pathname.new('test/fixtures/reference_excel_sheets.xlsx')],
          sheet_ids: %w[Wordings]
        )

        assert_equal 1, @created_files.size
        wording = Parsers::CSVParser.new.call(csv_path: @created_files.first.path, export_request: Requests::ExportRequest.new)

        assert_nil wording['en'].singulars['ignored_key']
        assert_equal 'Delete', wording['en'].singulars['delete'].value
      end

      test 'downloads remote excel file before converting it to csv' do
        response = Struct.new(:code, :body) { def [](header); end }
        body = File.binread('test/fixtures/reference_whitespace_stripping.xlsx')
        requests = []
        http = Struct.new(:requests, :response) do
          def request(request)
            requests << request
            response
          end
        end.new(requests, response.new('200', body))

        Net::HTTP.stub(:start, ->(*, **, &block) { block.call(http) }) do
          with_env('MICROSOFT_GRAPH_ACCESS_TOKEN' => 'token') do
            @created_files = @repository.convert_to_csvs(
              paths: [Pathname.new('https://example.com/reference_whitespace_stripping.xlsx')],
              sheet_ids: Requests::ExportRequest::DEFAULTS[:sheet_ids]
            )
          end
        end

        assert_equal 'graph.microsoft.com', requests.first.uri.hostname
        expected_path = '/v1.0/shares/u!aHR0cHM6Ly9leGFtcGxlLmNvbS9yZWZlcmVuY2Vfd2hpdGVzcGFjZV9zdHJpcHBpbmcueGxzeA/driveItem/content'
        assert_equal expected_path, requests.first.uri.path
        assert_equal 'Bearer token', requests.first['Authorization']
        assert_equal 1, @created_files.size
        wording = Parsers::CSVParser.new.call(csv_path: @created_files.first.path, export_request: Requests::ExportRequest.new)

        assert_equal 'before', wording['en'].singulars['before'].value
      end

      private

      def with_env(values)
        old_values = values.keys.to_h { |key| [key, ENV.fetch(key, nil)] }
        values.each { |key, value| ENV[key] = value }
        yield
      ensure
        old_values.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
      end
    end
  end
end
