module AdLocalize
  class OptionHandler
    def self.parse!(options)
      option_parser = OptionParser.new do |parser|
        parser.banner = "Usage: exe/ad_localize [options] file(s)"

        parser.on("-d", "--debug", TrueClass, "Run in debug mode")
        parser.on("-e", "--export-all-sheets", TrueClass,
                  <<~DOC
                    Export all sheets from spreadsheet specified by --drive-key option.
                    \tBy default, generates one export directory per sheet (see -m|--merge-sheets option to merge them).
                    \tAn GCLOUD_CLIENT_SECRET environment variable containing the client_secret.json content is needed.
        DOC
        )
        parser.on("-h", "--help", "Prints help") do
          puts parser
          exit
        end
        parser.on("-k", "--drive-key SPREADSHEET_ID", String, "Use google drive spreadsheets")
        parser.on("-m", "--merge-policy POLICY", String,
                  <<~DOC
                    Merge specified csv (or sheets from --export-all) instead of exporting each csv.
                    \treplace: if a key is already defined, replace its value.
                    \tkeep: if a key is already defined, keep the previous value.
        DOC
        )
        parser.on("-o", "--only PLATFORMS", Array, "PLATFORMS is a comma separated list. Only generate localisation files for the specified platforms. Supported platforms : #{Requests::ExportRequest::SUPPORTED_PLATFORMS.to_sentence}")
        parser.on("-s", "--sheets SHEET_IDS", Array, "SHEET_IDS is a comma separated list. Use a specific sheet id for Google Drive spreadsheets with several sheets")
        parser.on("-t", "--target-dir PATH", String, "Path to the target directory")
        parser.on("-x", "--non-empty-values", TrueClass, "Do not export keys with empty values (iOS only)")
      end

      args = {}
      option_parser.parse!(options, into: args)
      args[:csv_paths] = options
      return args
    end
  end
end