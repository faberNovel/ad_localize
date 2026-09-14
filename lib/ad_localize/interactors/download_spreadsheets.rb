# frozen_string_literal: true
module AdLocalize
  module Interactors
    class DownloadSpreadsheets
      def initialize
        @drive_repository = Repositories::DriveRepository.new
        @office_repository = Repositories::OfficeRepository.new
      end

      def call(export_request:)
        return download_google_spreadsheets(export_request: export_request) if export_request.has_sheets?
        return download_office_spreadsheets(export_request: export_request) if export_request.has_excel_file?

        []
      end

      private

      def download_google_spreadsheets(export_request:)
        LOGGER.debug("Downloading spreadsheets")
        if export_request.export_all
          @drive_repository.download_all_sheets(spreadsheet_id: export_request.spreadsheet_id)
        else
          @drive_repository.download_sheets_by_id(spreadsheet_id: export_request.spreadsheet_id,
                                                  sheet_ids: export_request.sheet_ids)
        end
      end

      def download_office_spreadsheets(export_request:)
        @office_repository.convert_to_csvs(paths: [export_request.excel_file], sheet_ids: export_request.sheet_ids)
      end
    end
  end
end
