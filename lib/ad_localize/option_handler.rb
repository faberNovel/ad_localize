module AdLocalize
  class OptionHandler
    GOOGLE_DRIVE_DOCUMENT_ID = { length: 32, regexp: /\A[\w-]+\Z/ }

    class << self
      def parse
        args = { debug: false, only: nil}

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: ruby bin/export [options] file(s)"


          opts.on("-h", "--help", "Prints help") do
            puts opts
            exit
          end
          opts.on("-d", "--debug", "Run in debug mode") do
            args[:debug] = true
            LOGGER.debug!
          end
          opts.on("-k", "--drive-key #{GOOGLE_DRIVE_DOCUMENT_ID.dig(:length)}_characters", String, "Use google drive spreadsheets") do |key|
            is_valid_drive_key = !!(key =~ GOOGLE_DRIVE_DOCUMENT_ID.dig(:regexp)) && (key.size >= GOOGLE_DRIVE_DOCUMENT_ID.dig(:length))
            raise ArgumentError.new("Invalid google drive spreadsheet key \"#{key}\"") unless is_valid_drive_key
            args[:drive_key] = key
          end
          opts.on("-e", "--export-all-sheets",
            <<~DOC
            Export all sheets from spreadsheet specified by --drive-key option.
            \tBy default, generates one export directory per sheet (see -m|--merge-sheets option to merge them).
            \tAn GCLOUD_CLIENT_SECRET environment variable containing the client_secret.json content is needed.
            DOC
          ) do
            args[:export_all_sheets] = true
          end
          opts.on("-m", "--merge-option OPTION", String,
            <<~DOC
            Merge specified csv (or sheets from --export-all) instead of exporting each csv.
            \treplace: if a key is already defined, replace its value.
            \tkeep: if a key is already defined, keep the previous value.
            \tAvailable options : #{Constant::MERGE_POLICIES.to_sentence}
            DOC
          ) do |option|
            is_valid_merge_option=Constant::MERGE_POLICIES.index(option)
            if !is_valid_merge_option
                raise ArgumentError.new("Invalid merge option \"#{option}\", available options : #{Constant::MERGE_POLICIES.to_sentence}")
            end
            args[:merge] = option
          end
          opts.on("-s", "--drive-sheet SHEET_ID", String, "Use a specific sheet id for Google Drive spreadsheets with several sheets") do |value|
            args[:sheet_id] = value
          end
          opts.on("-a", "--use-service-account", "Use a Google Cloud Service Account to access the file. An GCLOUD_CLIENT_SECRET environment variable containing the client_secret.json content is needed.") do
            args[:use_service_account] = true
          end
          opts.on("-o", "--only platform1,platform2", Array, "Only generate localisation files for the specified platforms. Supported platforms : #{Constant::SUPPORTED_PLATFORMS.join(', ')}") do |platforms|
            args[:only] = filter_option_args("-o", platforms) { |platform| !!Constant::SUPPORTED_PLATFORMS.index(platform) }
          end
          opts.on("-t", "--target-dir PATH", String, "Path to the target directory") do |output_path|
            pn = Pathname.new(output_path)
            if pn.directory? and pn.readable? and pn.writable?
              args[:output_path] = output_path
            else
              raise ArgumentError.new("Invalid target directory. Check the permissions")
            end
          end
        end

        begin
          opt_parser.parse!
        rescue OptionParser::MissingArgument => e
          LOGGER.log(:error, :red, "Missing argument for option #{e.args.join(',')}")
        rescue ArgumentError => e
          LOGGER.log(:error, :red, e.message)
          raise e
        end
        args
      end

      private
      def filter_option_args(option, args)
        result = args.select { |arg| yield(arg) }
        invalid_args = args - result
        LOGGER.log(:debug, :red, "Invalid arg(s) for option #{option}: #{invalid_args.join(', ')}") unless invalid_args.empty?
        result
      end
    end
  end
end
