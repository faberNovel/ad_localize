module AdLocalize
  module Mappers
    class OptionsToExportRequest
      def map(options:)
        Requests::ExportRequest.new(
          platform_codes: options[:only],
          g_spreadsheet_options: map_g_spreadsheet_options(options: options),
          verbose: options[:debug],
          output_path: options[:'target-dir'],
          merge_policy: options[:'merge-policy'],
          csv_paths: options[:csv_paths]
        )
      end

      private

      def map_g_spreadsheet_options(options:)
        return unless options[:drive_key]
        Requests::GSpreadsheetOptions.new(
          spreadsheet_id: options[:'drive-key'],
          sheet_ids: options[:'sheets'],
          export_all: options[:'export-all-sheets'],
          service_account_config: ENV['GCLOUD_CLIENT_SECRET']
        )
      end
    end
  end
end