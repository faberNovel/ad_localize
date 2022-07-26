module AdLocalize
  module Interactors
    class ExportCSVFiles
      def initialize(csv_path_to_wording: nil)
        @csv_path_to_wording = csv_path_to_wording.presence || Mappers::CSVPathToWording.new
        @merge_wordings = MergeWordings.new
        @export_wording = ExportWording.new
      end

      def call(export_request:)
        LOGGER.debug("Starting export csv files : #{export_request.csv_paths.to_sentence}")
        wordings = export_request.csv_paths.map { |csv_path| @csv_path_to_wording.map(csv_path: csv_path) }.compact
        return if wordings.blank?

        wording = @merge_wordings.call(wordings: wordings, merge_policy: export_request.merge_policy)
        @export_wording.call(export_request: export_request, wording: wording)
      end
    end
  end
end