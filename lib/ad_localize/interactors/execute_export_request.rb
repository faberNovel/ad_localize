module AdLocalize
  module Interactors
    class ExecuteExportRequest
      def initialize(csv_parser: nil, value_range_to_wording: nil)
        @csv_parser = csv_parser
        @value_range_to_wording = value_range_to_wording
      end

      def call(export_request:)
        export_request.verbose? ? LOGGER.debug! : LOGGER.info!
        LOGGER.debug(export_request)
        LOGGER.debug("Checking request validity")
        return unless export_request.valid?

        if export_request.has_csv_files?
          ExportCSVFiles.new(csv_parser: @csv_parser).call(export_request: export_request)
        elsif export_request.has_g_spreadsheet_options?
          ExportGSpreadsheet.new(value_range_to_wording: @value_range_to_wording).call(export_request: export_request)
        end
        LOGGER.debug("End of export request execution")
      end
    end
  end
end