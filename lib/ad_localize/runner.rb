module AdLocalize
  class Runner
    attr_accessor :options

    def initialize
      @options = OptionHandler.parse
    end

    def run(args = ARGV)
        LOGGER.log(:info, :green, "OPTIONS : #{options}")
        input_files = args
        has_drive_key = options.dig(:drive_key)
        missing_csv_file = input_files.length.zero? and !has_drive_key
        raise 'No CSV to parse. Use option -h to see how to use this script' if missing_csv_file

        files_to_parse = []
        if has_drive_key
            LOGGER.log(:warn, :yellow, 'CSV file are ignored with the drive key option') if args.length > 1
            options[:drive_file] = CsvFileManager.download_from_drive(options.dig(:drive_key), options.dig(:sheet_id), options.dig(:use_service_account))
            files_to_parse.push(options.dig(:drive_file))
        else
            files_to_parse += input_files
        end
        LOGGER.log(:debug, :black, "FILES: #{files_to_parse}")
        if files_to_parse.length > 1
            export_all(files_to_parse)
        else
            export(files_to_parse.first)
        end
        CsvFileManager.delete_drive_file(options[:drive_file]) if options[:drive_file]
    end

    private

    def export_all(files)
        CsvFileManager.select_csvs(files).each do |file|
            export(file, File.basename(file, ".csv"))
        end
    end

    def export(file, output_path_suffix="")
      LOGGER.log(:info, :green, "********* PARSING #{file} *********")
      LOGGER.log(:info, :green, "Extracting data from file...")
      parser = CsvParser.new
      data = parser.extract_data(file)
      if data.empty?
        LOGGER.log(:error, :red, "No data were found in the file - check if there is a key column in the file")
      else
        export_platforms = options.dig(:only) || Constant::SUPPORTED_PLATFORMS
        add_intermediate_platform_dir = export_platforms.length > 1
        output_path = option_output_path_or_default
        export_platforms.each do |platform|
          platform_formatter = "AdLocalize::Platform::#{platform.to_s.camelize}Formatter".constantize.new(
            parser.locales.first,
            output_path + '/' + output_path_suffix,
            add_intermediate_platform_dir
          )
          parser.locales.each do |locale|
            platform_formatter.export(locale, data)
          end
        end
      end
    end

    def option_output_path_or_default
        options.dig(:output_path).presence || AdLocalize::Constant::EXPORT_FOLDER
    end
  end
end
