module AdLocalize
  module Mappers
    class OptionsToExportRequest
      def map(options:)
        Requests::ExportRequest.new(
          locales: options[:locales],
          bypass_empty_values: options[:'non-empty-values'],
          csv_paths: options[:csv_paths],
          merge_policy: options[:'merge-policy'],
          output_path: options[:'target-dir'],
          platforms: options[:only],
          spreadsheet_id: options[:'drive-key'],
          sheet_ids: options[:'sheets'],
          export_all: options[:'export-all-sheets'],
          verbose: options[:debug]
        )
      end
    end
  end
end
