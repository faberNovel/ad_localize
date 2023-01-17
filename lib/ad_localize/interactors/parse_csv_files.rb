module AdLocalize
  module Interactors
    class ParseCSVFiles
      def initialize
        @csv_parser = Parsers::CSVParser.new
      end

      def call(export_request:)
        LOGGER.debug("Starting export csv files : #{export_request.csv_paths.to_sentence}")
        wordings = export_request.csv_paths.filter_map { |csv_path| @csv_parser.call(csv_path:, export_request:) }
        return if wordings.blank?
        
        MergeWordings.new.call(wordings: wordings, merge_policy: export_request.merge_policy)
      end
    end
  end
end
