# frozen_string_literal: true
module AdLocalize
  module Interactors
    class ParseCSVFiles
      def initialize
        @csv_parser = Parsers::CSVParser.new
      end

      def call(export_request:)
        csv_paths = export_request.all_csv_paths
        LOGGER.debug("Will parse #{csv_paths.size} csv files")
        wordings = csv_paths.filter_map do |csv_path|
          @csv_parser.call(csv_path: csv_path, export_request: export_request)
        end
        LOGGER.debug("#{wordings.size} wording contents detected")
        return if wordings.blank?

        MergeWordings.new.call(wordings: wordings, merge_policy: export_request.merge_policy)
      end
    end
  end
end
