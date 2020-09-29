module AdLocalize
  module Interactors
    class ExecuteExportRequest
      def call(export_request:)
        return unless export_request.valid?
        if export_request.has_csv_files?
          ExportCSVFiles.new.call(export_request: export_request)
        elsif export_request.has_g_spreadsheet_options?
          ExportGSpreadsheet.new.call(export_request: export_request)
        end
      end
    end
  end
end