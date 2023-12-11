# frozen_string_literal: true
module AdLocalize
  module Repositories
    class DriveRepository
      def initialize
        @drive_service = Google::Apis::DriveV3::DriveService.new
        @sheet_service = Google::Apis::SheetsV4::SheetsService.new
        if ENV['GOOGLE_APPLICATION_CREDENTIALS']
          drive_scope = [Google::Apis::DriveV3::AUTH_DRIVE_READONLY]
          sheet_scope = [Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY]
          @drive_service.authorization = Google::Auth.get_application_default(drive_scope)
          @sheet_service.authorization = Google::Auth.get_application_default(sheet_scope)
        end
      end

      def download_sheets_by_id(spreadsheet_id:, sheet_ids:)
        sheet_ids.filter_map do |sheet_id|
          begin
            url = export_url(spreadsheet_id: spreadsheet_id, sheet_id: sheet_id)
            string = @drive_service.http(:get, url, options: { retries: 5, max_elapsed_time: 120 })
            next unless string

            tempfile = Tempfile.new
            tempfile.write(string)
            tempfile.rewind
            tempfile
          rescue => e
            LOGGER.error("Cannot download sheet with id #{sheet_id}. Error: #{e.message}")
            nil
          end
        end
      end

      def download_all_sheets(spreadsheet_id:)
        begin
          spreadsheet = @sheet_service.get_spreadsheet(spreadsheet_id)
          sheet_ids = spreadsheet.sheets.map { |sheet| sheet.properties.sheet_id }
          LOGGER.debug("#{sheet_ids.size} sheets in the spreadsheet")
          download_sheets_by_id(spreadsheet_id: spreadsheet_id, sheet_ids: sheet_ids)
        rescue => e
          LOGGER.error("Cannot download sheets. Error: #{e.message}")
          []
        end
      end

      private

      def export_url(spreadsheet_id:, sheet_id:)
        "https://docs.google.com/spreadsheets/d/#{spreadsheet_id}/export?format=csv&gid=#{sheet_id}"
      end
    end
  end
end
