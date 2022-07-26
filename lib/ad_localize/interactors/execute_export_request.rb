module AdLocalize
  module Interactors
    class ExecuteExportRequest
      def initialize(csv_path_to_wording: nil, value_range_to_wording: nil)
        @csv_path_to_wording = csv_path_to_wording
        @value_range_to_wording = value_range_to_wording
      end

      def call(export_request:)
        export_request.verbose? ? LOGGER.debug! : LOGGER.info!
        print_export_request(export_request: export_request) if export_request.verbose?
        LOGGER.debug("Checking request validity")
        return unless export_request.valid?

        if export_request.has_csv_files?
          ExportCSVFiles.new(csv_path_to_wording: @csv_path_to_wording).call(export_request: export_request)
        elsif export_request.has_g_spreadsheet_options?
          ExportGSpreadsheet.new(value_range_to_wording: @value_range_to_wording).call(export_request: export_request)
        end
        LOGGER.debug("End of export request execution")
      end

      private

      def print_export_request(export_request:)
        LOGGER.debug("Export Request info")
        LOGGER.debug("locales : #{export_request.locales.to_sentence}")
        LOGGER.debug("platforms : #{export_request.platforms.to_sentence}")
        LOGGER.debug("output_path : #{export_request.output_path}")
        LOGGER.debug("verbose : #{export_request.verbose}")
        LOGGER.debug("non_empty_values : #{export_request.non_empty_values}")
        LOGGER.debug("merge_policy : #{export_request.merge_policy&.policy}")
        LOGGER.debug("csv_paths : #{export_request.csv_paths.to_sentence}")
        if export_request.has_g_spreadsheet_options?
          g_options = export_request.g_spreadsheet_options
          LOGGER.debug("spreadsheet_id : #{g_options.spreadsheet_id}")
          LOGGER.debug("sheet_ids : #{g_options.sheet_ids.to_sentence}")
          LOGGER.debug("export_all: #{g_options.export_all}")
          LOGGER.debug("service_account: #{g_options.service_account_config.present?}")
        end
        LOGGER.debug("End Export Request info")
      end
    end
  end
end