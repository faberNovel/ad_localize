# frozen_string_literal: true
module AdLocalize
  module Interactors
    class ProcessExportRequest
      def call(export_request:)
        export_request.verbose ? LOGGER.debug! : LOGGER.info!
        LOGGER.debug(export_request)
        LOGGER.debug("Verify if there are CSV to process")
        return unless export_request.has_csv_paths?

        LOGGER.debug("Parse CSV files")
        wording = ParseCSVFiles.new.call(export_request: export_request)
        return unless wording

        LOGGER.debug("Export wording")
        ExportWording.new.call(export_request: export_request, wording: wording)
        LOGGER.debug("End of export request execution")
      end
    end
  end
end
