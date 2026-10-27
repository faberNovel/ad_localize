# frozen_string_literal: true
module AdLocalize
  module Repositories
    class OfficeRepository
      EXCEL_EXTENSION = '.xlsx'
      GRAPH_ACCESS_TOKEN_ENV = 'MICROSOFT_GRAPH_ACCESS_TOKEN'
      GRAPH_URL = 'https://graph.microsoft.com/v1.0'
      GRAPH_BLOCK_CELLS = 100_000

      def office_source?(path:)
        File.extname(URI(path.to_s).path) == EXCEL_EXTENSION
      rescue URI::InvalidURIError
        false
      end

      def convert_to_csvs(paths:, sheet_ids:, export_all: false)
        paths.flat_map do |path|
          convert_to_csv(path: path, sheet_ids: sheet_ids, export_all: export_all)
        end
      end

      private

      def convert_to_csv(path:, sheet_ids:, export_all:)
        return convert_remote_to_csv(path: path, sheet_ids: sheet_ids, export_all: export_all) if remote_source?(path)

        workbook = RubyXL::Parser.parse(path.to_s)
        worksheets = worksheets_for(workbook: workbook, sheet_ids: sheet_ids, path: path, export_all: export_all)
        worksheets.map { |worksheet| write_csv(worksheet: worksheet) }
      rescue StandardError => e
        LOGGER.error("Cannot convert Excel file #{path}. Error: #{e.message}")
        []
      end

      # Remote files are read through the Excel API instead of being downloaded, so recent
      # edits made in SharePoint are taken into account.
      def convert_remote_to_csv(path:, sheet_ids:, export_all:)
        graph_access_token
        LOGGER.debug("Reading Excel file #{path} through Microsoft Graph Excel API")
        workbook_uri = graph_workbook_uri(path: path)
        names = graph_json(uri: URI("#{workbook_uri}/worksheets")).fetch('value').map { |sheet| sheet.fetch('name') }
        select_sheet_names(names: names, sheet_ids: sheet_ids, path: path, export_all: export_all).map do |name|
          write_rows_csv(rows: graph_sheet_rows(workbook_uri: workbook_uri, sheet_name: name))
        end
      end

      # Graph limits the size of a response, so large sheets are read by blocks of rows
      def graph_sheet_rows(workbook_uri:, sheet_name:)
        sheet_uri = "#{workbook_uri}/worksheets('#{URI.encode_www_form_component(sheet_name).gsub('+', '%20')}')"
        used = graph_json(uri: URI("#{sheet_uri}/usedRange(valuesOnly=true)?$select=rowIndex,columnIndex,rowCount,columnCount"))
        first_column = column_letters(used.fetch('columnIndex'))
        last_column = column_letters(used.fetch('columnIndex') + used.fetch('columnCount') - 1)
        block_size = [GRAPH_BLOCK_CELLS / used.fetch('columnCount'), 1].max
        first_row = used.fetch('rowIndex') + 1
        last_row = used.fetch('rowIndex') + used.fetch('rowCount')
        first_row.step(last_row, block_size).flat_map do |start_row|
          address = "#{first_column}#{start_row}:#{last_column}#{[start_row + block_size - 1, last_row].min}"
          graph_json(uri: URI("#{sheet_uri}/range(address='#{address}')?$select=values")).fetch('values')
        end
      end

      def column_letters(index)
        letters = +''
        index += 1
        while index.positive?
          index, remainder = (index - 1).divmod(26)
          letters.prepend((65 + remainder).chr)
        end
        letters
      end

      def graph_json(uri:)
        response = get(uri: uri)
        raise "HTTP #{response.code}: #{response.body}" unless (200..299).cover?(response.code.to_i)

        JSON.parse(response.body)
      end

      def graph_workbook_uri(path:)
        # The Excel API is not available through the /shares addressing: resolve the drive item first
        item = graph_json(uri: URI("#{GRAPH_URL}/shares/#{share_id(url: path.to_s)}/driveItem?$select=id,parentReference"))
        drive_id = item.fetch('parentReference').fetch('driveId')
        URI("#{GRAPH_URL}/drives/#{drive_id}/items/#{item.fetch('id')}/workbook")
      end

      def get(uri:)
        request = Net::HTTP::Get.new(uri)
        # Graph redirects to a pre-authenticated download URL: never leak the token to another host
        request['Authorization'] = "Bearer #{graph_access_token}" if uri.hostname == URI(GRAPH_URL).hostname
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
      end

      def share_id(url:)
        encoded_url = Base64.urlsafe_encode64(url, padding: false)
        "u!#{encoded_url}"
      end

      def graph_access_token
        ENV.fetch(GRAPH_ACCESS_TOKEN_ENV, '').presence ||
          raise("Missing #{GRAPH_ACCESS_TOKEN_ENV} environment variable")
      end

      def worksheets_for(workbook:, sheet_ids:, path:, export_all:)
        names = workbook.worksheets.map(&:sheet_name)
        select_sheet_names(names: names, sheet_ids: sheet_ids, path: path, export_all: export_all).map do |name|
          workbook.worksheets.find { |sheet| sheet.sheet_name == name }
        end
      end

      def select_sheet_names(names:, sheet_ids:, path:, export_all:)
        return names if export_all
        return names.first(1) if sheet_ids == Requests::ExportRequest::DEFAULTS[:sheet_ids]

        sheet_ids.select do |sheet_id|
          names.include?(sheet_id).tap do |found|
            LOGGER.error("Cannot find Excel sheet named #{sheet_id} in #{path}") unless found
          end
        end
      end

      def write_csv(worksheet:)
        write_rows_csv(rows: worksheet.map { |row| (row&.cells || []).map { |cell| cell&.value } })
      end

      def write_rows_csv(rows:)
        file = Tempfile.new(['ad_localize', '.csv'])
        CSV.open(file.path, 'w') do |csv|
          rows.each { |row| csv << row }
        end
        file.rewind
        file
      end

      def remote_source?(path)
        raise "Only https URLs are supported for Excel files: #{path}" if path.to_s.start_with?('http://')

        path.to_s.start_with?('https://')
      end
    end
  end
end
