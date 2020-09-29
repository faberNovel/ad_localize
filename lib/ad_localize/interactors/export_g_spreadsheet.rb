module AdLocalize
  module Interactors
    class ExportGSpreadsheet
      def initialize
        @value_range_to_wording = Mappers::ValueRangeToWording.new
        @g_sheets_repository = Repositories::GSheetsRepository.new
      end

      def call(export_request:)
        if export_request.g_spreadsheet_options.service_account_config
          export_with_service_account(export_request: export_request)
        else
          export_without_service_account(export_request: export_request)
        end
      end

      private

      def export_with_service_account(export_request:)
        value_ranges = @g_sheets_repository.get_sheets_values(export_request.g_spreadsheet_options)
        wordings = value_ranges.map { |value_range| @value_range_to_wording.map(value_range: value_range) }
        wording = MergeWordings.new.call(wordings: wordings.compact, merge_policy: export_request.merge_policy)
        ExportWording.new.call(export_request: export_request, wording: wording)
      end

      def export_without_service_account(export_request:)
        downloaded_files = export_request.g_spreadsheet_options.public_download_urls.map do |sheet_download_url|
          download_public_sheet(url: sheet_download_url)
        end
        export_request.csv_paths = downloaded_files.map(&:path)
        ExportCSVFiles.new.call(export_request: export_request)
        downloaded_files.select { |downloaded_file| File.exist?(downloaded_file.path) }.each do |downloaded_file|
          downloaded_file.close
          downloaded_file.unlink
        end
      end

      def download_public_sheet(url:)
        tempfile = Tempfile.new
        URI.open(url) do |uri_io|
          tempfile.write uri_io.read
          tempfile.rewind
        end
        tempfile
      end
    end
  end
end