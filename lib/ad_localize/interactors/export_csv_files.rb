module AdLocalize
  module Interactors
    class ExportCSVFiles
      def initialize
        @csv_file_to_wording = Mappers::CSVFileToWording.new
        @merge_wordings = MergeWordings.new
      end

      def call(export_request:)
        wordings = export_request.csv_paths.map do |csv_path|
          csv_file = WordingSources::CSVFile.new(path: csv_path)
          @csv_file_to_wording.map(csv_file: csv_file)
        end
        wording = @merge_wordings.call(wordings: wordings.compact, merge_policy: export_request.merge_policy)
        ExportWording.new.call(export_request: export_request, wording: wording)
      end
    end
  end
end