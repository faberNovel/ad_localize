module AdLocalize
  class CLI
    def self.start(args:)
      options = OptionHandler.parse!(args)
      export_request = Mappers::OptionsToExportRequest.new.map(options: options)
      if export_request.has_g_spreadsheet_options?
        export_request.csv_paths = DownloadSpreadsheets.new.call(export_request: export_request)
      else
        export_request.csv_paths = options[:csv_paths]
      end
      
      Interactors::ExecuteExportRequest.new.call(export_request: export_request)
    end
  end
end