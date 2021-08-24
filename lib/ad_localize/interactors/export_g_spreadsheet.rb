module AdLocalize
  module Interactors
    class ExportGSpreadsheet
      def initialize(value_range_to_wording: nil)
        @value_range_to_wording = value_range_to_wording.presence || Mappers::ValueRangeToWording.new
        @g_sheets_repository = Repositories::GSheetsRepository.new
      end

      def call(export_request:)
        LOGGER.debug("Starting export google spreadsheet")
        if export_request.g_spreadsheet_options.service_account_config
          export_with_service_account(export_request: export_request)
        else
          export_without_service_account(export_request: export_request)
        end
      end

      private

      def export_with_service_account(export_request:)
        LOGGER.debug("Using service account")
        value_ranges = @g_sheets_repository.get_sheets_values(g_spreadsheet_options: export_request.g_spreadsheet_options)
        wordings = value_ranges.map { |value_range| @value_range_to_wording.map(value_range: value_range) }
        wording = MergeWordings.new.call(wordings: wordings.compact, merge_policy: export_request.merge_policy)
        ExportWording.new.call(export_request: export_request, wording: wording)
      end

      def export_without_service_account(export_request:)
        LOGGER.debug("Using direct access to spreadsheet")
        downloaded_files = export_request.g_spreadsheet_options.public_download_urls.map do |sheet_download_url|
          download_public_sheet(url: sheet_download_url)
        end
        export_request.csv_paths = downloaded_files.map(&:path)
        if export_request.has_csv_files?
          ExportCSVFiles.new.call(export_request: export_request)
        else
          if export_request.has_empty_files?
            # When downloading an empty spreadsheet, the content type of the downloaded file is "inode/x-empty"
            LOGGER.warn("Your spreadsheet is empty. Add content and retry.")
          else
            # When shared configuration is misconfigured, the content type of the downloaded file is "text/html"
            LOGGER.error("Invalid export request. Check the spreadsheet share configuration")
          end
        end
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