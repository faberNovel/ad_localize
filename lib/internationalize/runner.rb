require 'active_support'
require 'active_support/core_ext'
require 'byebug'
require 'fileutils'
require_relative 'ad_logger'
require_relative 'constant'
require_relative 'option_handler'
require_relative 'csv_parser'
require_relative 'csv_file_manager'
Internationalize::Constant::SUPPORTED_PLATFORMS.each { |platform| require_relative "platform_formatters/#{platform}_formatter" }

module Internationalize
  LOGGER = ADLogger.new

  class Runner
    attr_accessor :options

    def initialize
      @options = OptionHandler.parse
    end

    def run
      LOGGER.log(:info, :black, "OPTIONS : #{options}")
      parser = CsvParser.new
      options[:drive_files] = options.dig(:drive_keys).map { |key| CsvFileManager.download_from_drive(key) }
      csvs = CsvFileManager.select_csvs(options.dig(:drive_files) + ARGV)
      csvs.each do |file|
        LOGGER.log(:info, :black, "********* PARSING #{file} *********")
        LOGGER.log(:info, :black, "Extracting data from file...")
        data = parser.extract_data(file)
        if data.empty?
          LOGGER.log(:error, :red, "No data were found in the file - cannot start the file generation process")
        else
          export_platforms = options.dig(:only) || Constant::SUPPORTED_PLATFORMS
          export_platforms.each do |platform|
            platform_formatter = "Internationalize::Platform::#{platform.to_s.camelize}Formatter".constantize.new(parser.locales.first, options.dig(:output_path))
            parser.locales.each do |locale|
              platform_formatter.export(locale, data)
            end
          end
        end
      end
      options[:drive_files].each{ |file| Pathname.new(file).delete }
    end
  end
end