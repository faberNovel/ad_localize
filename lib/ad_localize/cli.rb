# frozen_string_literal: true
module AdLocalize
  class CLI
    def self.start(args:)
      options = OptionHandler.parse!(args)
      export_request = Mappers::OptionsToExportRequest.new.map(options: options)
      if export_request.has_sheets?
        export_request.downloaded_csvs = DownloadSpreadsheets.new.call(export_request: export_request)
      end
      Interactors::ProcessExportRequest.new.call(export_request: export_request)
    ensure
      export_request.downloaded_csvs.each do |file|
        file.close
        file.unlink
      end
    end
  end
end
