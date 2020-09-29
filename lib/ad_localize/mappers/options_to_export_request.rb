module AdLocalize
  module Mappers
    class OptionsToExportRequest
      def map(options:)
        ExportRequest.new(
          platform_codes: options[:only],
          g_spreadsheet_options: map_g_spreadsheet_options(options: options),
          verbose: options[:debug],
          output_path: options[:output_path],
          merge_policy: options[:merge]
        )
      end

      private

      def map_g_spreadsheet_options(options:)
        return unless options[:drive_key]
        Requests::GSpreadsheetOptions.new(
          spreadsheet_id: options[:drive_key],
          sheet_ids: options[:sheet_id],
          export_all: options[:export_all_sheets],
          service_account_config: ENV['GCLOUD_CLIENT_SECRET']
        )
      end
    end
  end
end