# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Repositories
    # Minimal in-memory Microsoft Graph Excel API
    class FakeGraph
      Response = Struct.new(:code, :body) { def [](_header); end }

      attr_reader :requests

      def initialize(sheets:, status:)
        @sheets = sheets
        @status = status
        @requests = []
      end

      def request(request)
        @requests << request
        Response.new(@status, body_for(URI.decode_www_form_component(request.path)).to_json)
      end

      private

      def body_for(path)
        return { id: 'item1', parentReference: { driveId: 'drive1' } } if path.include?('/driveItem')
        return { value: @sheets.keys.map { |name| { name: name } } } if path.end_with?('/worksheets')

        rows = @sheets.fetch(path[/worksheets\('([^']+)'\)/, 1], [])
        return used_range(rows) if path.include?('usedRange')

        first, last = path[/address='([^']+)'/, 1].scan(/\d+/).map(&:to_i)
        { values: rows[(first - 1)...last] }
      end

      def used_range(rows)
        { rowIndex: 0, columnIndex: 0, rowCount: rows.size, columnCount: rows.first&.size.to_i }
      end
    end

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

      test 'converts all excel sheets to csv when export all is requested' do
        @created_files = @repository.convert_to_csvs(
          paths: [Pathname.new('test/fixtures/reference_excel_sheets.xlsx')],
          sheet_ids: Requests::ExportRequest::DEFAULTS[:sheet_ids],
          export_all: true
        )

        assert_equal 2, @created_files.size
      end

      test 'rejects non https remote excel files' do
        Net::HTTP.stub(:start, ->(*) { flunk 'no request expected' }) do
          @created_files = @repository.convert_to_csvs(
            paths: [Pathname.new('http://example.com/reference.xlsx')],
            sheet_ids: Requests::ExportRequest::DEFAULTS[:sheet_ids]
          )
        end

        assert_empty @created_files
      end

      test 'reads remote excel through graph excel api when a token is provided' do
        requests = stub_graph(sheets: { 'Wordings' => [%w[key en], %w[hello Hello]], 'Other' => [%w[key en]] }) do
          @created_files = convert_remote(token: 'token')
        end

        assert(requests.none? { |request| request.path.end_with?('/content') })
        assert(requests.all? { |request| request['Authorization'] == 'Bearer token' })
        assert_equal 1, @created_files.size
        wording = Parsers::CSVParser.new.call(csv_path: @created_files.first.path, export_request: Requests::ExportRequest.new)

        assert_equal 'Hello', wording['en'].singulars['hello'].value
      end

      test 'reads all remote excel sheets when export all is requested' do
        stub_graph(sheets: { 'Wordings' => [%w[key en]], 'Other' => [%w[key en]] }) do
          @created_files = convert_remote(token: 'token', export_all: true)
        end

        assert_equal 2, @created_files.size
      end

      test 'reads selected remote excel sheets and skips unknown ones' do
        stub_graph(sheets: { 'Wordings' => [%w[key en]], 'Other' => [%w[key en]] }) do
          @created_files = convert_remote(token: 'token', sheet_ids: %w[Other Missing])
        end

        assert_equal 1, @created_files.size
      end

      test 'reads large remote sheets by blocks of rows' do
        rows = Array.new(7) { |i| ["key#{i}", 'value'] }
        requests = stub_graph(sheets: { 'Wordings' => rows }, block_cells: 6) do
          @created_files = convert_remote(token: 'token')
        end

        addresses = requests.filter_map { |request| request.path[/range\(address='([^']+)'\)/, 1] }
        assert_equal %w[A1:B3 A4:B6 A7:B7], addresses
        assert_equal rows.map { |row| row.join(',') }, File.readlines(@created_files.first.path, chomp: true)
      end

      test 'does not convert remote excel when the graph token is missing' do
        Net::HTTP.stub(:start, ->(*) { flunk 'no request expected' }) do
          with_env('MICROSOFT_GRAPH_ACCESS_TOKEN' => nil) do
            logged = capture_error_log { @created_files = convert_remote(token: nil) }

            assert_includes logged, 'Missing MICROSOFT_GRAPH_ACCESS_TOKEN environment variable'
          end
        end

        assert_empty @created_files
      end

      test 'does not convert remote excel when graph returns an error' do
        logged = capture_error_log do
          stub_graph(sheets: {}, status: '403') { @created_files = convert_remote(token: 'token') }
        end

        assert_includes logged, 'HTTP 403'
        assert_empty @created_files
      end

      private

      def convert_remote(token:, **options)
        with_env('MICROSOFT_GRAPH_ACCESS_TOKEN' => token) do
          @repository.convert_to_csvs(
            paths: [Pathname.new('https://example.com/reference.xlsx')],
            sheet_ids: Requests::ExportRequest::DEFAULTS[:sheet_ids], **options
          )
        end
      end

      def stub_graph(sheets:, status: '200', block_cells: OfficeRepository::GRAPH_BLOCK_CELLS, &block)
        graph = FakeGraph.new(sheets: sheets, status: status)
        stub_block_cells(block_cells) do
          Net::HTTP.stub(:start, ->(*, **, &http_block) { http_block.call(graph) }, &block)
        end
        graph.requests
      end

      def stub_block_cells(value)
        original = OfficeRepository::GRAPH_BLOCK_CELLS
        OfficeRepository.send(:remove_const, :GRAPH_BLOCK_CELLS)
        OfficeRepository.const_set(:GRAPH_BLOCK_CELLS, value)
        yield
      ensure
        OfficeRepository.send(:remove_const, :GRAPH_BLOCK_CELLS)
        OfficeRepository.const_set(:GRAPH_BLOCK_CELLS, original)
      end

      def capture_error_log(&)
        messages = []
        LOGGER.stub(:error, ->(message) { messages << message }, &)
        messages.join("\n")
      end

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
