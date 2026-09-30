# frozen_string_literal: true
module AdLocalize
  module Repositories
    class OfficeRepository
      EXCEL_EXTENSION = '.xlsx'
      GRAPH_ACCESS_TOKEN_ENV = 'MICROSOFT_GRAPH_ACCESS_TOKEN'
      GRAPH_URL = 'https://graph.microsoft.com/v1.0'

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
        source_file = download(path: path) if remote_source?(path)
        workbook = RubyXL::Parser.parse(source_file&.path || path.to_s)
        worksheets = worksheets_for(workbook: workbook, sheet_ids: sheet_ids, path: path, export_all: export_all)
        worksheets.map { |worksheet| write_csv(worksheet: worksheet) }
      rescue StandardError => e
        LOGGER.error("Cannot convert Excel file #{path}. Error: #{e.message}")
        []
      ensure
        source_file&.close
        source_file&.unlink
      end

      def download(path:)
        file = Tempfile.new(['ad_localize', EXCEL_EXTENSION])
        file.binmode
        file.write(download_body(uri: graph_content_uri(path: path)))
        file.rewind
        file
      end

      def download_body(uri:, limit: 5)
        raise 'Too many redirects' if limit.zero?

        response = get(uri: uri)
        case response.code.to_i
        when 200..299
          response.body
        when 300..399
          redirect_uri = URI.join(uri, response['location'])
          raise "Refusing to follow non-https redirect to #{redirect_uri.hostname}" unless redirect_uri.scheme == 'https'

          download_body(uri: redirect_uri, limit: limit - 1)
        else
          raise "HTTP #{response.code}: #{response.body}"
        end
      end

      def get(uri:)
        request = Net::HTTP::Get.new(uri)
        # Graph redirects to a pre-authenticated download URL: never leak the token to another host
        request['Authorization'] = "Bearer #{graph_access_token}" if uri.hostname == URI(GRAPH_URL).hostname
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
      end

      def graph_content_uri(path:)
        URI("#{GRAPH_URL}/shares/#{share_id(url: path.to_s)}/driveItem/content")
      end

      def share_id(url:)
        encoded_url = Base64.urlsafe_encode64(url, padding: false)
        "u!#{encoded_url}"
      end

      def graph_access_token
        ENV.fetch(GRAPH_ACCESS_TOKEN_ENV) do
          raise "Missing #{GRAPH_ACCESS_TOKEN_ENV} environment variable"
        end
      end

      def worksheets_for(workbook:, sheet_ids:, path:, export_all:)
        return workbook.worksheets if export_all
        return [workbook.worksheets.first] if sheet_ids == Requests::ExportRequest::DEFAULTS[:sheet_ids]

        sheet_ids.filter_map do |sheet_id|
          worksheet = workbook.worksheets.find { |sheet| sheet.sheet_name == sheet_id }
          LOGGER.error("Cannot find Excel sheet named #{sheet_id} in #{path}") unless worksheet
          worksheet
        end
      end

      def write_csv(worksheet:)
        file = Tempfile.new(['ad_localize', '.csv'])
        CSV.open(file.path, 'w') do |csv|
          worksheet.each do |row|
            csv << (row&.cells || []).map { |cell| cell&.value }
          end
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
