module AdLocalize
  module Interactors
    class DownloadSpreadsheets
      def initialize
        @drive_repository = Repositories::DriveRepository.new
      end

      def call(export_request:)
        LOGGER.debug("Downloading spreadsheets")
        if export_request.export_all
          @drive_repository.download_all_sheets(spreadsheet_id: export_request.spreadsheet_id)
        else
          @drive_repository.download_sheets_by_id(spreadsheet_id: export_request.spreadsheet_id, sheet_ids: export_request.sheet_ids)
        end
      end
    end
  end
end
