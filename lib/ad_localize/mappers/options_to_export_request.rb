# frozen_string_literal: true
module AdLocalize
  module Mappers
    class OptionsToExportRequest
      def map(options:)
        request = Requests::ExportRequest.new
        request.locales = options[:locales]
        request.bypass_empty_values = options[:'non-empty-values']
        request.csv_paths = options[:csv_paths]
        request.merge_policy = options[:'merge-policy']
        request.output_path = options[:'target-dir']
        request.platforms = options[:only]
        request.spreadsheet_id = options[:'drive-key']
        request.sheet_ids = options[:sheets]
        request.export_all = options[:'export-all-sheets']
        request.verbose = options[:debug]
        request
      end
    end
  end
end
