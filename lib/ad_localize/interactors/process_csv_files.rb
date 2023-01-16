module AdLocalize
  module Interactors
    class ProcessCSVFiles
      def call(export_request:)
        export_request.verbose? ? LOGGER.debug! : LOGGER.info!
        LOGGER.debug(export_request)
        LOGGER.debug("Checking request validity")
        return unless export_request.valid?

        wording = ParseCSVFiles.new.call(export_request: export_request)
        ExportWording.new.call(export_request: export_request, wording: wording)
        LOGGER.debug("End of export request execution")
      end
    end
  end
end