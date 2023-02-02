# frozen_string_literal: true
module AdLocalize
  class CLI
    def self.start(args:)
      downloaded_files = []
      options = OptionHandler.parse!(args)
      export_request = Mappers::OptionsToExportRequest.new.map(options: options)
      if export_request.has_sheets?
        downloaded_files = DownloadSpreadsheets.new.call(export_request: export_request)
        export_request.csv_paths.concat(downloaded_files)
      end
      Interactors::ExecuteExportRequest.new.call(export_request: export_request)
    ensure
      downloaded_files.each do |file|
        file.close
        file.unlink
      end
    end
  end
end
