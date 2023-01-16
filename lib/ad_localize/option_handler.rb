module AdLocalize
  class OptionHandler
    DEFAULT_EXPORT_FOLDER = 'exports'.freeze
    DEFAULT_OPTIONS = {
      locales: [],
      bypass_empty_values: false,
      csv_paths: [],
      merge_policy: Requests::Request::MergePolicy::DEFAULT_POLICY,
      output_path: Pathname.new(DEFAULT_EXPORT_FOLDER),
      spreadsheet_id: nil,
      sheet_ids: [],
      export_all: false,
      verbose: false
    }

    def self.parse!(options)
      args = DEFAULT_OPTIONS

      option_parser = OptionParser.new do |parser|
        parser.banner = BANNER
        parser.on("-d", "--debug", TrueClass, 'DEBUG_DESCRIPTION') do
          args[:verbose] = true
        end
        parser.on("-e", "--export-all-sheets", TrueClass, 'EXPORT_ALL_DESCRIPTION') do
          args[:export_all] = true
        end
        parser.on("-h", "--help", 'HELP_DESCRIPTION') do
          puts parser
          exit
        end
        parser.on("-k", "--drive-key SPREADSHEET_ID", String, 'SPREADSHEET_DESCRIPTION') do |spreadsheet_id|
          args[:spreadsheet_id] = spreadsheet_id
        end
        parser.on("-m", "--merge-policy POLICY", String, 'MERGE_POLICY_DESCRIPTION') do |policy|
          args[:policy] = policy
        end
        parser.on("-o", "--only PLATFORMS", Array, 'PLATFORM_FILTER_DESCRIPTION') do |platforms|
          args[:platforms] = platforms
        end
        parser.on("-s", "--sheets SHEET_IDS", Array, 'SHEET_DESCRIPTION') do |sheet_ids|
          args[:sheet_ids] = sheet_ids
        end
        parser.on("-t", "--target-dir PATH", String, "OUTPUT_PATH_DESCRIPTION") do |output_path|
          args[:output_path] = output_path
        end
        parser.on("-x", "--non-empty-values", TrueClass, "Do not export keys with empty values (iOS only)") do |bypass|
          args[:bypass_empty_values] = bypass
        end
        parser.on("-v", "--version", "Prints current version") do
          puts AdLocalize::VERSION
          exit
        end
      end

      option_parser.parse!(options, into: args)
      args[:csv_paths] = options
      return 
    end
  end
end