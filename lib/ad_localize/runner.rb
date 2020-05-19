module AdLocalize
  class Runner
    attr_accessor :options

    def initialize
      @options = OptionHandler.parse
    end

    def run(args = ARGV)
      LOGGER.log(:info, :green, "OPTIONS : #{options}")
      input_files = (args + [options.dig(:drive_key)]).compact # drive_key can be nil
      if input_files.length.zero?
        LOGGER.log(:error, :red, "No CSV to parse. Use option -h to see how to use this script")
      else
        file_to_parse = args.first
        LOGGER.log(:warn, :yellow, "Only one CSV can be treated - the priority goes to #{file_to_parse}") if input_files.length > 1
        if args.empty?
          options[:drive_file] = CsvFileManager.download_from_drive(options.dig(:drive_key), options.dig(:sheet_id), options.dig(:use_service_account))
          file_to_parse = options.dig(:drive_file)
        end
        if CsvFileManager.csv?(file_to_parse)
          export(file_to_parse)
        else
          LOGGER.log(:error, :red, "#{file_to_parse} is not a csv. Make sure to enable \"Allow external access\" in sharing options or use a service account.")
        end
        CsvFileManager.delete_drive_file(options[:drive_file]) if options[:drive_file]
      end
    end

    private

    def export(file)
      LOGGER.log(:info, :green, "********* PARSING #{file} *********")
      LOGGER.log(:info, :green, "Extracting data from file...")
      parser = CsvParser.new
      data = parser.extract_data(file)
      if data.empty?
        LOGGER.log(:error, :red, "No data were found in the file - check if there is a key column in the file")
      else
        export_platforms = options.dig(:only) || Constant::SUPPORTED_PLATFORMS
        add_intermediate_platform_dir = export_platforms.length > 1
        export_platforms.each do |platform|
          platform_formatter = "AdLocalize::Platform::#{platform.to_s.camelize}Formatter".constantize.new(
            parser.locales.first,
            options.dig(:output_path),
            add_intermediate_platform_dir
          )
          parser.locales.each do |locale|
            platform_formatter.export(locale, data)
          end
        end
      end
    end
  end
end
