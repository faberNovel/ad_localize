# frozen_string_literal: true
module AdLocalize
  class OptionHandler
    DEFAULT_OPTIONS = {
      locales: Requests::ExportRequest::DEFAULTS[:locales],
      :'non-empty-values' => Requests::ExportRequest::DEFAULTS[:bypass_empty_values],
      :'auto-escape-percent' => Requests::ExportRequest::DEFAULTS[:auto_escape_percent],
      csv_paths: Requests::ExportRequest::DEFAULTS[:csv_paths],
      :'merge-policy' => Requests::ExportRequest::DEFAULTS[:merge_policy],
      :'target-dir' => Requests::ExportRequest::DEFAULTS[:output_path],
      :'drive-key' => Requests::ExportRequest::DEFAULTS[:spreadsheet_id],
      sheets: Requests::ExportRequest::DEFAULTS[:sheet_ids],
      :'export-all-sheets' => Requests::ExportRequest::DEFAULTS[:export_all],
      debug: Requests::ExportRequest::DEFAULTS[:verbose],
      only: Requests::ExportRequest::DEFAULTS[:platforms]
    }

    def self.parse!(options)
      args = DEFAULT_OPTIONS
      OptionParser.new do |parser|
        parser.banner = 'Usage: exe/ad_localize [options] file(s)'
        parser.on("-d", "--debug", TrueClass, 'Run in debug mode')
        export_all_option(parser)
        parser.on("-h", "--help", 'Prints help') do
          puts parser
          exit
        end
        parser.on("-k", "--drive-key SPREADSHEET_ID", String, 'Use google drive spreadsheets')
        parser.on("-l", "--locales LOCALES", Array,
                  'LOCALES is a comma separated list. Only generate localisation files for the specified locales')
        merge_policy_option(parser)
        platforms_option(parser)
        parser.on("-s", "--sheets SHEET_IDS", Array,
                  'SHEET_IDS is a comma separated list. Use a specific sheet id for Google Drive spreadsheets with several sheets')
        parser.on("-t", "--target-dir PATH", String, 'Path to the target directory')
        parser.on("-v", "--version", 'Prints current version') do
          puts AdLocalize::VERSION
          exit
        end
        parser.on("-x", "--non-empty-values", TrueClass, 'Do not export keys with empty values (iOS only)')
        parser.on("--auto-escape-percent", TrueClass, 'Add escaping for % symbol to support wording use with String formatting (iOS only)')
      end.parse!(options, into: args)

      args[:csv_paths] = options
      return args
    end

    def self.export_all_option(parser)
      export_all_option = <<~DOC
        Export all sheets from spreadsheet specified by --drive-key option.
        \tBy default, generates one export directory per sheet (see -m|--merge-sheets option to merge them).
        \tAn GCLOUD_CLIENT_SECRET environment variable containing the client_secret.json content is needed.
      DOC
      parser.on("-e", "--export-all-sheets", TrueClass, export_all_option)
    end

    def self.merge_policy_option(parser)
      merge_policy_option = <<~DOC
        Merge specified csv (or sheets from --export-all) instead of exporting each csv.
        \treplace: if a key is already defined, replace its value.
        \tkeep: if a key is already defined, keep the previous value.
      DOC
      parser.on("-m", "--merge-policy POLICY", Interactors::MergeWordings::MERGE_POLICIES, merge_policy_option)
    end

    def self.platforms_option(parser)
      platforms_option = <<~DOC
        PLATFORMS is a comma separated list.
        \tOnly generate localisation files for the specified platforms.
        \tSupported platforms : #{Entities::Platform::SUPPORTED_PLATFORMS.to_sentence}
      DOC
      parser.on("-o", "--only PLATFORMS", Array, platforms_option)
    end
  end
end
