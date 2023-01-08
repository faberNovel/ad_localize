module AdLocalize
  module Interactors
    class ExportCSVFiles
      def initialize(csv_path_to_wording: nil)
        # @csv_path_to_wording = csv_path_to_wording.presence || Mappers::CSVPathToWording.new
        @csv_path_to_wording = csv_path_to_wording.presence || Parsers::CSVParser.new
      end

      def call(export_request:)
        LOGGER.debug("Starting export csv files : #{export_request.csv_paths.to_sentence}")
        options = { locales: export_request.locales, bypass_empty_values: export_request.non_empty_values }
        wordings = export_request.csv_paths.filter_map { |csv_path| @csv_path_to_wording.call(csv_path:, options:) }
        return if wordings.blank?

        wording = MergeWordings.new.call(wordings: wordings, merge_policy: export_request.merge_policy)
        ExportWording.new.call(export_request: export_request, wording: wording)
      end
    end
  end
end