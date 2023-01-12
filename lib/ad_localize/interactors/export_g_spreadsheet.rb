module AdLocalize
  module Interactors
    class ExportGSpreadsheet
      def initialize
        @drive_repository = Repositories::DriveRepository.new
        @export_csv_files = ExportCSVFiles.new
      end

      def call(export_request:)
        LOGGER.debug("Starting export google spreadsheet")
        export_request.csv_paths = download_files(export_request:)
        ExportCSVFiles.new.call(export_request:)
      ensure
        export_request.csv_paths.each do |file|
          file.close
          file.unlink
        end
      end

      private

      def download_files(export_request:)
        if export_request.g_spreadsheet_options.export_all
          @drive_repository.download_all_sheets(spreadsheet_id: export_request.g_spreadsheet_options.spreadsheet_id)
        else
          @drive_repository.download_sheets_by_id(spreadsheet_id: export_request.spreadsheet_id, sheet_ids: export_request.g_spreadsheet_options.sheet_ids)
        end
      end
    end
  end
end